From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (2/8) convert sdla to new initialization
Date: Fri, 5 Sep 2003 02:50:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030905025042.2ff7939d.davem@redhat.com>
References: <20030903164925.5c44ce73.shemminger@osdl.org>
	<20030905070619.A13947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mike.mclagan@linux.org, jgarzik@pobox.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20030905070619.A13947@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Sep 2003 07:06:19 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Sep 03, 2003 at 04:49:25PM -0700, Stephen Hemminger wrote:
> >  extern int mac8390_probe(struct net_device *dev);
> >  extern int mac89x0_probe(struct net_device *dev);
> >  extern int mc32_probe(struct net_device *dev);
> > +#ifdef CONFIG_SDLA
> > +extern struct net_device *sdla_init(void);
> > +#endif
> 
> Please don't add ifdefs around prototypes.

I fixed this all up.
