From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] sis900 printk audit
Date: Sun, 23 Jan 2005 17:16:47 +0100
Message-ID: <20050123161647.GA1917@electric-eye.fr.zoreil.com>
References: <20050122214657.18649.66345@localhost.localdomain> <20050122222640.GB24461@electric-eye.fr.zoreil.com> <20050123085229.GD31816@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, NetDev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <20050123085229.GD31816@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano <webvenza@libero.it> :
[...]
> Is that a suggestion that I make some global variable or macro to avoid
> repeating that declaration in almost every function of the driver ?

It suggests turning:

	struct sis900_private *sis_priv = net_dev->priv;

into:

	struct sis900_private *sis_priv = netdev_priv(net_dev);

--
Ueimor
