From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 13:34:04 -0700 (PDT)
Message-ID: <20050712.133404.52118192.davem@davemloft.net>
References: <20050707222741.71C3E89826@linux.site>
	<20050712202754.GA10768@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghavendra.koushik@neterion.com, jgarzik@pobox.com, netdev@oss.sgi.com,
        ravinandan.arakali@neterion.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@infradead.org
In-Reply-To: <20050712202754.GA10768@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 12 Jul 2005 21:27:54 +0100

> > +/* Enable 2 buffer mode by default for SGI system */
> > +#ifdef CONFIG_IA64_SGI_SN2
> > +#define CONFIG_2BUFF_MODE
> > +#endif
> 
> this enabled it only on kernel that are built to only run on SN2
> hardware, which is completely useless in practice.  Besides that defining
> a CONFIG_ symbol from source files is a big no-go.

Yes, do this in the Kconfig file instead.
