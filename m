From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 27 Jun 2007 18:32:45 -0400
Message-ID: <1182983565.5155.12.camel@localhost>
References: <1182790051.5184.29.camel@localhost>
	 <20070625.134741.129320846.davem@davemloft.net>
	 <1182864448.5186.34.camel@localhost>
	 <20070626.135756.30187055.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:38752 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759790AbXF0Wct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 18:32:49 -0400
Received: by wx-out-0506.google.com with SMTP id h31so323744wxd
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 15:32:49 -0700 (PDT)
In-Reply-To: <20070626.135756.30187055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-26-06 at 13:57 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Tue, 26 Jun 2007 09:27:28 -0400
> 
> > Back to the question: Do you recall how this number was arrived at? 
> > 128 packets will be sent out at GiGe in about 80 microsecs, so from a
> > feel-the-wind-direction perspective it seems reasonable.
> 
> I picked it out of a hat.

It is not a bad value for Gige; doubt it will be a good one for 10/100
or even 10GE.
But you could say that about the ring sizes too.

cheers,
jamal

