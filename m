From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Tue, 15 Jul 2008 12:27:29 -0700
Message-ID: <adak5fndk2m.fsf@cisco.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:43993 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757994AbYGOTjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 15:39:48 -0400
In-Reply-To: <487B6569.5000806@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 14 Jul 2008 17:40:41 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > +	MLX4_EN_FLAG_HIGH_DMA   = 1 << 2,
 > +	MLX4_EN_FLAG_FW_RUNNING = 1 << 3

I don't see anywhere that sets either of these flags.  The test of
HIGH_DMA seems strange:

 > +	if (mdev->mlx4_en_flags & MLX4_EN_FLAG_HIGH_DMA)
 > +		dev->features |= NETIF_F_HIGHDMA;

I think you can safely assume that an mlx4 device can DMA to any bus
address, and just set NETIF_F_HIGHDMA unconditionally.
