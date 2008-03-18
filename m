From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 0/7][MV643XX_ETH] various cleanups
Date: Tue, 18 Mar 2008 09:14:06 -0700
Message-ID: <20080318161406.GA27913@farnsworth.org>
References: <20080317191546.GA17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:50149 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbYCTGHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 02:07:43 -0400
Content-Disposition: inline
In-Reply-To: <20080317191546.GA17828@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2008 at 08:15:46PM +0100, Lennert Buytenhek wrote:
> Hi all,
> 
> This patch series performs various cleanups of mv643xx_eth, and moves
> it into the direction of being able to be instantiated multiple times
> -- which is currently not possible due to the driver using static
> variables, identifying ports by their port index within the single
> supported instance[*] instead of a pointer to a describing structure,
> and such.
> 
> The goal of multiple instantiation isn't achieved yet by this patch
> set, since it requires some changes in how mv643xx_eth platform
> devices are instantiated which in turn requires some changes in
> arch/{ppc,powerpc} which haven't been fully sorted out and agreed
> upon yet -- but this patch set is a step in the general direction,
> and the maintainer has informally ACKed these patches previously
> (in private mail), so I'm seeking wider feedback on them now.

Hi Lennert,

I'm happy with the end result, but the current patch series will
not build after patches 1-3 are applied.  Please reorder your
code changes so the result will be git-bisectable.

-Dale
