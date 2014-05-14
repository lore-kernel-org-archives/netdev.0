From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Wed, 14 May 2014 19:28:08 +0200
Message-ID: <136925813.20140514192808@eikelenboom.it>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com> <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com> <53734F9F.2010101@citrix.com> <1400067318.7973.69.camel@edumazet-glaptop2.roam.corp.google.com> <53736EBA.7050401@citrix.com> <1400085639.26934.17.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:45933 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaENR2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 13:28:13 -0400
In-Reply-To: <1400085639.26934.17.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Wednesday, May 14, 2014, 6:40:39 PM, you wrote:


> On Wed, 2014-05-14 at 14:25 +0100, Zoltan Kiss wrote:

>> But of course it should be carefully checked that functions which place 
>> frags into another frags arrays should call orphan_frags, e.g. I guess 
>> skb_shift does such thing. That's what I intend to start another thread 
>> about.

> I see Eric has posted a fix for skb_try_coalesce(), but is that likely
> to be acceptable for 3.15? How many other similar patches are we
> expecting and/or how long do you think this careful checking will take?

> Given that we are now at 3.15-rc5 I think we need to decide how to
> proceed, either push ahead fixing all these issues or (partially) revert
> this netback feature and try again for 3.16.

> Ian.

Hi Zoltan,

Thanks for the patch, and for what it's worth:

With Zoltan's v3 patch, I have ran the same tests as i did while reporting the 
regression and when that worked out ok stressed netback and netfront some extra this afternoon.
The patch fixes the regression for me, no corruption, no problems with SSL 
connections anymore and i haven't spotted anything else.

So as a fix for the immediate regression you may put on a tested-by :-)

On the discussion about the rest of the fallout i don't think i contribute that 
much.

--
Sander
