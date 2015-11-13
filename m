From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH] net: phy: vitesse: add support for VSC8601
Date: Fri, 13 Nov 2015 09:51:26 +0100
Message-ID: <5645A48E.9090402@free.fr>
References: <1447353672-4365-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mans Rullgard <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447353672-4365-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2015 19:41, Mans Rullgard wrote:

> +	.phy_id         = PHY_ID_VSC8601,
> +	.name           = "Vitesse VSC8601",
> +	.phy_id_mask    = 0x000ffff0,
> +	.features       = PHY_GBIT_FEATURES,
> +	.flags          = PHY_HAS_INTERRUPT,
> +	.config_init    = &genphy_config_init,
> +	.config_aneg    = &genphy_config_aneg,
> +	.read_status    = &genphy_read_status,
> +	.ack_interrupt  = &vsc824x_ack_interrupt,
> +	.config_intr    = &vsc82xx_config_intr,

I expected Documentation/CodingStyle to forbid taking the address
of functions.

Regards.
