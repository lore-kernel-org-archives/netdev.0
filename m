From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/5] sis900 printk audit
Date: Sun, 23 Jan 2005 19:31:55 +0100
Message-ID: <20050123183155.GF31816@picchio.gall.it>
References: <20050122214657.18649.66345@localhost.localdomain> <20050122222640.GB24461@electric-eye.fr.zoreil.com> <20050123085229.GD31816@gateway.milesteg.arr> <20050123161647.GA1917@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20050123161647.GA1917@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 23, 2005 at 05:16:47PM +0100, Francois Romieu wrote:
> It suggests turning:
> 
> 	struct sis900_private *sis_priv = net_dev->priv;
> 
> into:
> 
> 	struct sis900_private *sis_priv = netdev_priv(net_dev);

Ah, that is indeed a good advice, I didn't even know that netdev_priv()
existed.

I'll put it on my todo list, all the driver should be converted to that
form.

Thanks.

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
