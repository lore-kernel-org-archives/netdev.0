From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 27 Jun 2007 20:15:47 -0400
Message-ID: <1182989747.5155.89.camel@localhost>
References: <1182864448.5186.34.camel@localhost>
	 <20070626.135756.30187055.davem@davemloft.net>
	 <1182983565.5155.12.camel@localhost>
	 <20070627.155457.35508432.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:28034 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289AbXF1APv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 20:15:51 -0400
Received: by wx-out-0506.google.com with SMTP id h31so347875wxd
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 17:15:51 -0700 (PDT)
In-Reply-To: <20070627.155457.35508432.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-27-06 at 15:54 -0700, David Miller wrote:

> The thing that's really important is that the value is not so
> large such that the TX ring can become empty.

In the case of batching, varying the values makes a difference.
The logic is that if you can tune it so that the driver takes
"sufficiently long" to stay closed the more packets you accumulate at
the qdisc and the more you can batch to the driver (when it opens up). 
Deciding what "sufficiently long" is an art - and i am sure speed
dependent. With e1000 at gige 128 seems to be a good value, going above
or below that gave lesser performance.

cheers,
jamal

