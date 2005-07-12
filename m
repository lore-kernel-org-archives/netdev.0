From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Tue, 12 Jul 2005 22:07:04 +0100
Message-ID: <20050712210704.GA11622@infradead.org>
References: <20050712.133404.52118192.davem@davemloft.net> <000a01c58724$ca41a7c0$4f10100a@pc.s2io.com> <20050712.140411.41107257.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ravinandan.arakali@neterion.com, hch@infradead.org,
        raghavendra.koushik@neterion.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050712.140411.41107257.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2005 at 02:04:11PM -0700, David S. Miller wrote:
> From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
> Subject: RE: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
> Date: Tue, 12 Jul 2005 14:00:52 -0700
> 
> > The two-buffer mode was added as a configurable option
> > to Kconfig file several months ago. Hence the macro
> > is CONFIG_2BUFF_MODE.
> 
> We're saying that you should choose CONFIG_2BUFF_MODE, when
> CONFIG_IA64_SGI_SN2 is set, inside the Kconfig file using the
> "default" Kconfig directive.

And that doesn't help either, CONFIG_IA64_SGI_SN2 isn't used in practice,
any production Altix with 26 kernels runs CONFIG_IA64_GENERIC kernels.

You have to make this run-time selectable.
