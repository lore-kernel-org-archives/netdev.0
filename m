From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH 12/14] [rndis_host] Add RNDIS physical medium checking
	into generic_rndis_bind()
Date: Sun, 27 Jan 2008 21:05:46 +0200
Message-ID: <1201460746.3663.18.camel@localhost>
References: <20080125225032.11716.77713.stgit@fate.lan>
	 <20080125225139.11716.91641.stgit@fate.lan>
	 <200801270829.53470.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	bjd@jooz.net
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:57043 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750936AbYA0TFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 14:05:55 -0500
In-Reply-To: <200801270829.53470.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2008-01-27 at 08:29 -0800, David Brownell wrote:
> Well, other than the obvious checkpatch.pl warnings waiting to trigger
> ("if" is not a function; put a space before the paren) and what I'd call
> missing parens around the "flags & ...", those are *not* errors.  No
> wonder you thought this would cause too many messages!!
Well, I guess I got lazy between patchsets. 

> Just make those be dev_dbg() calls instead.  The strongest message level
> you can argue for there would be KERN_NOTICE, "normal but significant";
> except it's not especially significant.  Filtering by netif_msg_probe()
> may be a good idea too; that's normally enabled in this framework.
I'll use dev_dbg() with netif_msg_probe().

> p.s. Before these get submitted, *all* of them need to pass "checkpatch.pl".
>   Ideally, "checkpatch.pl --strict" ...
Ok, I'll remember that now.

I'm not very familiar with posting patches (as some might have noticed)
so I have some questions.. if you don't mind. Now that you have acked
most of the patches, is it ok for me to add your 'Acked-by' to those
patches? Should I even repost all of these patches as patchset or just
ones that have been fixed? Should I post new 'physical medium' patch as
reply to this post and then repost patchset with your ack just to
mailing list?

 - Jussi Kivilinna

