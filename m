From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Thu, 17 Jul 2008 23:30:58 +0200
Message-ID: <20080717213058.GA28252@orion.carnet.hr>
References: <20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com> <487B7061.5040306@trash.net> <20080714172055.GA2638@ami.dom.local> <20080714202151.GA28622@orion.carnet.hr> <20080714212223.GA4849@ami.dom.local> <20080714212620.GA8503@orion.carnet.hr> <20080714214851.GB4849@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:40806 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756367AbYGQVbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 17:31:08 -0400
Content-Disposition: inline
In-Reply-To: <20080714214851.GB4849@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 11:48:51PM +0200, Jarek Poplawski wrote:
> > OK, I'll give it a whirl.
> > 
> > (Should I update to .26 at the same time, now that it went live in the
> > meantime?)
> 
> My proposal is to try .25 first.

It looks like the patch fixed my issues - no relevant printk's appeared
since I've applied it, so apparently there is no more cloned skb splitting
or corrupted data getting to bnx2.

I used the latest variant, from Jarek's mail
<20080714212223.GA4849@ami.dom.local>, on the 2.6.25.6 kernel.

Thanks all!

(Now if only someone could make sure this propagates into the stable kernel
branches, since those were pretty nasty crashes...)

-- 
     2. That which causes joy or happiness.
