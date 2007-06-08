From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 08 Jun 2007 07:34:57 -0400
Message-ID: <1181302497.4063.37.camel@localhost>
References: <1181253445.4071.4.camel@localhost>
	 <20070607.154421.109060486.davem@davemloft.net>
	 <1181256848.4071.57.camel@localhost>
	 <20070607.160035.00774597.davem@davemloft.net>
	 <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com>
	 <1181266536.4741.27.camel@localhost>
	 <20070608103925.GA23598@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:60801 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968629AbXFHLfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 07:35:02 -0400
Received: by wx-out-0506.google.com with SMTP id t15so702196wxc
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2007 04:35:02 -0700 (PDT)
In-Reply-To: <20070608103925.GA23598@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-08-06 at 20:39 +1000, Herbert Xu wrote:

> It would guard against the poll routine which would acquire this lock
> when cleaning the TX ring.

Ok, then i suppose we can conclude it is a bug on e1000 (holds tx_lock
on tx side and adapter queue lock on rx). Adding that lock will
certainly bring down the performance numbers on a send/recv profile.
The bizare thing is things run just fine even under the heavy tx/rx
traffic i was testing under. I guess i didnt hit hard enough.

cheers,
jamal

