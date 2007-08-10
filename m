From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 04/18] via-rhine: disable rx_copybreak on archs that don't allow unaligned DMA access
Date: Fri, 10 Aug 2007 23:33:04 +0200
Message-ID: <20070810213304.GB5301@electric-eye.fr.zoreil.com>
References: <200708102105.l7AL5FUp008954@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, jailbird@alcatraz.fdf.net,
	ink@jurassic.park.msu.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33577 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbXHJVhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 17:37:07 -0400
Content-Disposition: inline
In-Reply-To: <200708102105.l7AL5FUp008954@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org <akpm@linux-foundation.org> :
> From: Dustin Marquess <jailbird@alcatraz.fdf.net>
> 
> Patch to disable the rx_copybreak feature on hardware architectures that
> don't allow unaligned DMA access.
> 
> #ifdef code taken from tulip_core.c.  Problem pointed out by Ivan
> Kokshaysky.

Color me confused but what are we trying to solve here ?

The rx_copybreak processing is performed after the DMA from the network
card to memory is done: DMA does not care about rx_copybreak. 

-- 
Ueimor
