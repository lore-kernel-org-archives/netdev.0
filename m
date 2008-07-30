From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: MV643xx Ethernet Driver Issue on a Motorola PrPMC-275 board.
Date: Thu, 31 Jul 2008 01:56:22 +0200
Message-ID: <20080730235622.GA22826@xi.wantstofly.org>
References: <488F5815.9020402@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Chris Larson <clarson@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:37055 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbYG3X4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:56:24 -0400
Content-Disposition: inline
In-Reply-To: <488F5815.9020402@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2008 at 10:49:09AM -0700, Chris Larson wrote:

> I was wondering if anyone had any advice on an issue a customer of ours 
> is running into.  When they run a series of bandwidth tests, slowly 
> increasing the bandwidth & # of tcp connections to roughly 30Mbit at 
> 4000 connections, their machine panics.  An address passed to 
> dma_unmap_single is beyond lowmem, as though it was corrupted in some 
> fashion.  The address is the data pointer in the ethernet dma 
> descriptors, it pulls a descriptor out of the ring in the packet receipt 
> functions and at that point the address is wrong.  Nowhere in the driver 
> is a descriptor set up with that address, yet the datasheet on the 
> mv643xx doesn't seem to indicate that the dma engine ever writes to the 
> descriptors themselves, only to the data they point to (as you'd 
> expect).  Does anyone have any ideas on this?  I'm afraid that I'm a bit 
> out of my depth on this issue.  The architecture is ppc.

I've never seen this happen.  Which kernel version is this on?
