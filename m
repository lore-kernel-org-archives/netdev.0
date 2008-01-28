From: Tino Keitel <tino.keitel@gmx.de>
Subject: Re: 2.6.24 regression: Wake On Lan in sky2 broken on Mac mini
Date: Mon, 28 Jan 2008 09:48:55 +0100
Message-ID: <20080128084855.GA5926@dose.home.local>
References: <20080128002934.GA6354@dose.home.local> <18333.37002.749771.524523@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:41849 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759932AbYA1Ist (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 03:48:49 -0500
Content-Disposition: inline
In-Reply-To: <18333.37002.749771.524523@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 09:21:30 +0100, Mikael Pettersson wrote:
> Tino Keitel writes:
>  > Hi folks,
>  > 
>  > with 2.6.24-rc8, Wake On LAN doesn't work anymore as it used to with
>  > 2.6.23 on my Mac mini Core Duo. I saw that this was reported in
>  > http://bugzilla.kernel.org/show_bug.cgi?id=9721 and on netdev a patch
>  > for the sky2 driver was sent by Stephen Hemminger. This patch fixed WOL
>  > for me after applying it to 2.6.24-rc8.
>  > 
>  > However, it seems as the patch never made it into the kernel. Instead,
>  > the commit that was suspected to break WOL
>  > (84cd2dfb04d23a961c5f537baa243fa54d0987ac) was reverted
>  > (be63a21c9573fbf88106ff0f030da5974551257b).
>  > 
>  > Now I tried the 2.6.24 release and noticed that WOL is still broken.
>  > I'll be happy to test any patches that can make it into 2.6.24.1.
> 
> 1. Wrong mailing list; use netdev (@vger) instead.

Done.

> 2. The reverted commit had much much more serious consequences than
>    "wol doesn't work", it actually caused BIOS hangs and failed reboots.

Yes, but even with the reverted commit, WOL still doesn't work. I just
tried the patch from the netdev mailing list with the 2.6.24 release
version and now WOL works for me.

Regards,
Tino
