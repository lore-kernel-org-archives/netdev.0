From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC 01/10] mlx4_en: Include file
Date: Tue, 15 Jul 2008 14:46:53 +0100
Message-ID: <20080715134651.GW19302@solarflare.com>
References: <487B6569.5000806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.co.il>, tziporet@mellanox.co.il,
	Roland Dreier <rdreier@cisco.com>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:39839 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755365AbYGONrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 09:47:07 -0400
Content-Disposition: inline
In-Reply-To: <487B6569.5000806@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yevgeny Petrilin wrote:
[...]
> +#ifdef CONFIG_MLX4_EN_DEBUG
> +#define mlx4_dbg(mdev, format, arg...)	\
> +	printk(KERN_DEBUG "%s %s: " format , DRV_NAME ,\
> +		(&mdev->pdev->dev)->bus_id , ## arg)

CONFIG_MLX4_EN_DEBUG isn't in Kconfig.  If you expect debugging to be
enabled through tweaking EXTRA_CFLAGS then the macro should be called
something else.

[...]
> +#ifdef CONFIG_MLX4_EN_PREFETCH
> +	#define PREFETCH(x)		prefetch(x)

Neither is CONFIG_MLX4_EN_PREFETCH in Kconfig.  Why don't you do this
unconditionally?

There are several more CONFIG macros tested here which should be removed
or renamed (or possibly added to Kconfig).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
