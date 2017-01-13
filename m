From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 08/10] net: dsa: Add support for platform data
Date: Fri, 13 Jan 2017 15:04:59 +0100
Message-ID: <20170113140459.GH10203@lunn.ch>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
 <20170112034121.27697-9-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM SUB-ARCHITECTURES"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>,
        gregkh@linuxfoundation.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170112034121.27697-9-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> index cd91070b5467..d326fc4afad7 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -81,17 +81,23 @@ static void dsa_dst_del_ds(struct dsa_switch_tree *dst,
>  
>  static bool dsa_port_is_valid(struct dsa_port *port)
>  {
> -	return !!port->dn;
> +	return !!(port->dn || port->name);
>  }
  
Does this clash with Viviens recent change to make names optional and
have the kernel assign it?

I suppose you could use an name of "eth%d"? Is it worth adding a
comment to the platform data structure?

	Andrew
