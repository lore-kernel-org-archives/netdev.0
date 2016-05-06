From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 12/21] net: dsa: mv88e6xxx: factorize switch
 reset
Date: Sat, 7 May 2016 00:27:58 +0200
Message-ID: <20160506222758.GC2073@lunn.ch>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462571843-14397-13-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462571843-14397-13-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index dbbda4e..b744ed5 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2551,6 +2551,68 @@ restore_page_0:
>  	return ret;
>  }
>  
> +static int _mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps)
> +{

You missed removing the _ prefix.

Thanks for removing the others. With so much less noise, it is easier
to review the patches.

   Andrew
