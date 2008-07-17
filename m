From: David Miller <davem@davemloft.net>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 17 Jul 2008 14:44:07 -0700 (PDT)
Message-ID: <20080717.144407.37848445.davem@davemloft.net>
References: <20080714212620.GA8503@orion.carnet.hr>
	<20080714214851.GB4849@ami.dom.local>
	<20080717213058.GA28252@orion.carnet.hr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: joy@entuzijast.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761067AbYGQVoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 17:44:08 -0400
In-Reply-To: <20080717213058.GA28252@orion.carnet.hr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josip Rodin <joy@entuzijast.net>
Date: Thu, 17 Jul 2008 23:30:58 +0200

> It looks like the patch fixed my issues - no relevant printk's appeared
> since I've applied it, so apparently there is no more cloned skb splitting
> or corrupted data getting to bnx2.
> 
> I used the latest variant, from Jarek's mail
> <20080714212223.GA4849@ami.dom.local>, on the 2.6.25.6 kernel.
> 
> Thanks all!
> 
> (Now if only someone could make sure this propagates into the stable kernel
> branches, since those were pretty nasty crashes...)

We will make sure the fix propagates in some form, thanks for testing.
