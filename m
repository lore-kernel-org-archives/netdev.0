From: Adrian Bunk <bunk@stusta.de>
Subject: Re: A new 10GB Ethernet Driver by Chelsio Communications
Date: Fri, 11 Mar 2005 23:58:31 +0100
Message-ID: <20050311225831.GQ3723@stusta.de>
References: <Pine.LNX.4.58.0503110356340.14213@server.graphe.net> <20050311112132.6a3a3b49.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <christoph@graphe.net>, linux-kernel@vger.kernel.org,
        mark@chelsio.com, netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050311112132.6a3a3b49.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 11, 2005 at 11:21:32AM -0800, Andrew Morton wrote:
> Christoph Lameter <christoph@graphe.net> wrote:
> >
> > A Linux driver for the Chelsio 10Gb Ethernet Network Controller by
> >  Chelsio (http://www.chelsio.com). This driver supports the Chelsio N210
> >  NIC and is backward compatible with the Chelsio N110 model 10Gb NICs.
> 
> Thanks, Christoph.
> 
> The 400k patch was too large for the vger email server so I have uploaded it to
> 
>  http://www.zip.com.au/~akpm/linux/patches/stuff/a-new-10gb-ethernet-driver-by-chelsio-communications.patch
> 
> for reviewers.
>...

- my3126.c is unused (because t1_my3126_ops isn't used anywhere)
- what are the EXTRA_CFLAGS in drivers/net/chelsio/Makefile for?
- $(cxgb-y) in drivers/net/chelsio/Makefile seems to be unneeded
- completely unused global functions:
  - espi.c: t1_espi_get_intr_counts
  - sge.c: t1_sge_get_intr_counts
- the following functions can be made static:
  - sge.c: t1_espi_workaround
  - sge.c: t1_sge_tx
  - subr.c: __t1_tpi_read
  - subr.c: __t1_tpi_write
  - subr.c: t1_wait_op_done


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
