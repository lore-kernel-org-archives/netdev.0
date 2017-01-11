From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/8] net: dsa: Export dev_to_net_device()
Date: Tue, 10 Jan 2017 21:24:57 -0500 (EST)
Message-ID: <20170110.212457.38085718141908018.davem@davemloft.net>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
        <20170110201235.21771-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com, linux@armlinux.org.uk,
        vivien.didelot@savoirfairelinux.com, tremyfr@gmail.com,
        schwidefsky@de.ibm.com, gregkh@linuxfoundation.org,
        stuart.yoder@nxp.com, ingo.tuchscherer@linux.vnet.ibm.com,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110201235.21771-6-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 10 Jan 2017 12:12:32 -0800

> @@ -491,7 +491,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
>  }
>  EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
>  
> -static struct net_device *dev_to_net_device(struct device *dev)
> +struct net_device *dev_to_net_device(struct device *dev)
>  {
>  	struct device *d;
>  
> @@ -508,6 +508,7 @@ static struct net_device *dev_to_net_device(struct device *dev)
>  
>  	return NULL;
>  }
> +EXPORT_SYMBOL_GPL(dev_to_net_device);

Something like this, a public interface with a very high level generic name,
doesn't belong in the DSA layer.  It belongs in net/core/dev.c or something
like that.
