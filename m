From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 21:27:54 +0100
Message-ID: <20050712202754.GA10768@infradead.org>
References: <20050707222741.71C3E89826@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: raghavendra.koushik@neterion.com
Content-Disposition: inline
In-Reply-To: <20050707222741.71C3E89826@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 3. Enable two-buffer mode(for Rx path) automatically for SGI
>    systems. This improves Rx performance dramatically on 
>    SGI systems.

> +/* Enable 2 buffer mode by default for SGI system */
> +#ifdef CONFIG_IA64_SGI_SN2
> +#define CONFIG_2BUFF_MODE
> +#endif

this enabled it only on kernel that are built to only run on SN2
hardware, which is completely useless in practice.  Besides that defining
a CONFIG_ symbol from source files is a big no-go.

What exactly is the 2buff mode, and more specific what are the downsides
of  enabling it on non-SGI hardware?
