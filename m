From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (2/8) convert sdla to new initialization
Date: Fri, 5 Sep 2003 07:06:19 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905070619.A13947@infradead.org>
References: <20030903164925.5c44ce73.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, mike.mclagan@linux.org,
   Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030903164925.5c44ce73.shemminger@osdl.org>; from shemminger@osdl.org on Wed, Sep 03, 2003 at 04:49:25PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 03, 2003 at 04:49:25PM -0700, Stephen Hemminger wrote:
>  extern int mac8390_probe(struct net_device *dev);
>  extern int mac89x0_probe(struct net_device *dev);
>  extern int mc32_probe(struct net_device *dev);
> +#ifdef CONFIG_SDLA
> +extern struct net_device *sdla_init(void);
> +#endif

Please don't add ifdefs around prototypes.
