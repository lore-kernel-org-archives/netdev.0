From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mvneta: implement SGMII-based in-band link state
 signaling
Date: Thu, 02 Apr 2015 20:51:31 -0400 (EDT)
Message-ID: <20150402.205131.1699226515102250937.davem@davemloft.net>
References: <551AA02B.2050104@list.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, f.fainelli@gmail.com
To: stsp@list.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <551AA02B.2050104@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stas Sergeev <stsp@list.ru>
Date: Tue, 31 Mar 2015 16:24:59 +0300

> @@ -2590,6 +2651,7 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
> 
>  static void mvneta_mdio_remove(struct mvneta_port *pp)
>  {
> +	fixed_phy_set_link_update(pp->phy_dev, NULL);

I do not see any other driver doing this on shutdown.
Please show me why it is necessary.

And if it is, all other drivers registering a fixed phy link update
function need to be adjusted to do the same thing.
