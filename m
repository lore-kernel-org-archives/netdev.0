From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Sun, 31 Jul 2005 15:05:15 +0100
Message-ID: <20050731140515.GA6261@infradead.org>
References: <20050712.140411.41107257.davem@davemloft.net> <001001c5945b$df8afd90$4810100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'David S. Miller'" <davem@davemloft.net>, hch@infradead.org,
        raghavendra.koushik@neterion.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, leonid.grossman@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Content-Disposition: inline
In-Reply-To: <001001c5945b$df8afd90$4810100a@pc.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2005 at 09:37:55AM -0700, Ravinandan Arakali wrote:
> David,
> We are trying to use the "default" directive in Kconfig. We tried
> using an unconditional directive(just to test it out) such as
> "default y" and a conditional one such as "default y if
> CONFIG_IA64_SGI_SN2".

Again, please make this a module option, CONFIG_IA64_SGI_SN2 does not
mean runs on Altix but that this is a kernel that only supports Altix,
which is a non-standard case that doesn't cover 90% or more of actual
Altix systems in the field and running 2.6.
