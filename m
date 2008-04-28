From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 1/5] mv643xx_eth: get rid of static variables, allow
	multiple instances
Date: Mon, 28 Apr 2008 11:22:53 -0700
Message-ID: <20080428182253.GB2691@farnsworth.org>
References: <20080423232702.GC17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51578 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936561AbYD1SXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 14:23:05 -0400
Content-Disposition: inline
In-Reply-To: <20080423232702.GC17159@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 01:27:02AM +0200, Lennert Buytenhek wrote:
> Move mv643xx_eth's static state (ethernet register block base address
> and MII management interface spinlock) into a struct hanging off the
> shared platform device.  This is necessary to support chips that
> contain multiple mv643xx_eth silicon blocks.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Acked-by: Nicolas Pitre <nico@marvell.com>

Acked-by: Dale Farnsworth <dale@farnsworth.org>

It would be good to at least copy linuxppc-dev@ozlabs.org on the
powerpc bits, but these changes may be simple enough for Jeff to
take without an ack from the Paul.

-Dale
