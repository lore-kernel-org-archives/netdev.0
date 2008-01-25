From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/5] [POWERPC][NET] ucc_geth_mii and users: get rid of
 device_type
Date: Fri, 25 Jan 2008 15:20:20 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0801251519500.20972@blarg.am.freescale.net>
References: <20080124151850.GA15190@localhost.localdomain>
 <20080124154001.GB23246@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52406 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756516AbYAYVXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 16:23:15 -0500
In-Reply-To: <20080124154001.GB23246@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jan 2008, Anton Vorontsov wrote:

> device_type property is bogus, thus use proper compatible.
>
> Also change compatible property to "fsl,ucc-mdio".
>
> Per http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048388.html
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
>  arch/powerpc/boot/dts/mpc832x_mds.dts |    3 +--
>  arch/powerpc/boot/dts/mpc832x_rdb.dts |    3 +--
>  arch/powerpc/boot/dts/mpc836x_mds.dts |    3 +--
>  arch/powerpc/boot/dts/mpc836x_rdk.dts |    3 +--
>  arch/powerpc/boot/dts/mpc8568mds.dts  |    2 +-
>  drivers/net/ucc_geth_mii.c            |    3 +++
>  6 files changed, 8 insertions(+), 9 deletions(-)
>

applied. (same comment about rdk)

- k
