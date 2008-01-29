From: maximilian attems <max@stro.at>
Subject: Re: sis190 build breakage
Date: Tue, 29 Jan 2008 23:27:19 +0100
Message-ID: <20080129222719.GS1446@baikonur.stro.at>
References: <20080129215023.GA24152@stro.at> <20080129220310.GC15445@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:58020 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbYA2W2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 17:28:16 -0500
Content-Disposition: inline
In-Reply-To: <20080129220310.GC15445@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2008 at 11:03:10PM +0100, Francois Romieu wrote:
> maximilian attems <max@stro.at> :
> >   CC [M]  drivers/net/sis190.o
> >   drivers/net/sis190.c:329: error: sis190_pci_tbl causes a section type conflict
> >   make[5]: *** [drivers/net/sis190.o] Error 1
> > 
> > gcc --version
> > gcc (GCC) 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)
> 
> Are you building latest git with DEBUG_SECTION_MISMATCH enabled by any
> misfortune ?

yep latest git, but nope
# CONFIG_DEBUG_SECTION_MISMATCH is not set

probably i should to get interesting info.
