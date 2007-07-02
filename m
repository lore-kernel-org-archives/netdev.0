From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
Subject: Re: [PATCH UPDATE #2] Extract chip specific code out of lasi_82596.c
Date: Mon, 2 Jul 2007 15:41:05 +0200
Message-ID: <20070702134105.GA7403@alpha.franken.de>
References: <20070627224622.GA13356@alpha.franken.de> <4688F2D8.6020308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:58177 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630AbXGBNl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 09:41:56 -0400
Content-Disposition: inline
In-Reply-To: <4688F2D8.6020308@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 02, 2007 at 08:43:04AM -0400, Jeff Garzik wrote:
> applied both patches.
> 
> Please provide an update that does at Andrew requested -- rather than 
> #include'ing lib82596.c, you should update the Makefile for relevant 
> drivers to look like

I got the impression that Andrew is fine with that approach after my
explanation. I would need additional header files for all the
different swap macros/dma stuff, and that isn't nice either, isn't it ? 

There are other drivers doing the same as I do, which didn't get any
objections. Is it me you have a prolem with ?

Thomas.

-- 
Crap can work. Given enough thrust pigs will fly, but it's not necessary a
good idea.                                                [ RFC1925, 2.3 ]
