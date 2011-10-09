From: Marc Ballarin <ballarin.marc@gmx.de>
Subject: Re: [PATCH] r8169: Fix WOL in power down case
Date: Sun, 9 Oct 2011 19:13:31 +0200
Message-ID: <20111009191331.cbfca0b6b724921f35fd8c41@gmx.de>
References: <20111007221906.810698ba9bf825566a2478bb@gmx.de>
	<20111007210017.GA27820@electric-eye.fr.zoreil.com>
	<20111007214200.GA28365@electric-eye.fr.zoreil.com>
	<20111008003156.ef4dfaa76576ca8079edfbb9@gmx.de>
	<20111007232834.GA29770@electric-eye.fr.zoreil.com>
	<20111009104907.0c6cd439900ca5eb7789295f@gmx.de>
	<20111009115438.GA12343@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:55762 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751850Ab1JIRNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 13:13:37 -0400
In-Reply-To: <20111009115438.GA12343@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 9 Oct 2011 13:54:38 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> ...
> Moreover, the patch duplicates a chunk of conditional code:
> 1) it bloats the driver (ok, we have seen worse...).
> 2) you can bet that both instances won't be updated if / when
>    RTL_GIGA_MAC_VER_xy appears.

I thought so ;-)

> 
> The patch below should fix it.

Yes, it works fine here. Thanks a lot.
