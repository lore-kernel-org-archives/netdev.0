From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: sun4i-emac: use phydev from struct
 net_device
Date: Wed, 22 Jun 2016 16:25:42 -0400 (EDT)
Message-ID: <20160622.162542.1929166668685308741.davem@davemloft.net>
References: <1466255740-20999-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxime.ripard@free-electrons.com, wens@csie.org,
	hdegoede@redhat.com, mugunthanvnm@ti.com, a@unstable.cc,
	fw@strlen.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750821AbcFVUZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:25:49 -0400
In-Reply-To: <1466255740-20999-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 18 Jun 2016 15:15:39 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied
