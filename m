From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: dsa: Fix cleanup resources upon module removal
Date: Tue, 8 Mar 2016 15:52:30 +0100
Message-ID: <20160308145230.GI351@lunn.ch>
References: <20151207.163608.1805578623951785262.davem@davemloft.net>
 <1457429780-7665-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, f.fainelli@gmail.com,
	rmk+kernel@arm.linux.org.uk, pavel.nakonechny@skitlab.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457429780-7665-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 08, 2016 at 10:36:20AM +0100, Neil Armstrong wrote:
> The initial commit badly merged into the dsa_resume method instead
> of the dsa_remove_dst method.
> As consequence, the dst->master_netdev->dsa_ptr is not set to NULL on
> removal and re-bind of the dsa device fails with error -17.
> 
> Fixes: b0dc635d923c ("net: dsa: cleanup resources upon module removal ")
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Acked-by: Andrew Lunn <andrew@lunn.ch>

Thanks

	Andrew
