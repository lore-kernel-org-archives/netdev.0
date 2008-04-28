From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 5/5] mv643xx_eth: inter-mv643xx SMI port sharing
Date: Mon, 28 Apr 2008 11:24:50 -0700
Message-ID: <20080428182450.GF2691@farnsworth.org>
References: <20080423232959.GG17159@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@cam.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:60414 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936853AbYD1SY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2008 14:24:58 -0400
Content-Disposition: inline
In-Reply-To: <20080423232959.GG17159@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 01:29:59AM +0200, Lennert Buytenhek wrote:
> There exist chips with up to four mv643xx_eth silicon blocks but
> only one external SMI (MII management) interface -- the SMI logic
> of the first block is shared by all the blocks.
> 
> Handle this by allowing a per-port override of which
> mv643xx_eth_shared's SMI registers (and spinlock) to use.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> Acked-by: Nicolas Pitre <nico@marvell.com>

Acked-by: Dale Farnsworth <dale@farnsworth.org>
