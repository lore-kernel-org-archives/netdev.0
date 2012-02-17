From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: Re: [PATCH V2 1/3] bluetooth: Add logging functions bt_info and
 bt_err
Date: Fri, 17 Feb 2012 11:38:47 +0200
Message-ID: <20120217093847.GA12814@x220>
References: <cover.1329461202.git.joe@perches.com>
 <5c5e8180081e57e6098139fadd9275073048f448.1329461203.git.joe@perches.com>
 <1329467859.28848.130.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1329467859.28848.130.camel@aeonflux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Feb 17, 2012, Marcel Holtmann wrote:
> Hi Joe,
> 
> > Use specific logging functions instead of a generic
> > bt_printk function can save some text.
> > 
> > Remove now unused bt_printk function.
> > Add compatibility BT_INFO and BT_ERR macros.
> > 
> > (compiled x86 and defconfig with bluetooth and all bluetooth drivers)
> > 
> > $ size net/bluetooth/built-in.o*
> >    text	   data	    bss	    dec	    hex	filename
> >  381662	  20072	 100416	 502150	  7a986	net/bluetooth/built-in.o.allyesconfig.new
> >  382463	  20072	 100400	 502935	  7ac97	net/bluetooth/built-in.o.allyesconfig.old
> >  126635	   1388	    132	 128155	  1f49b	net/bluetooth/built-in.o.defconfig.new
> >  127175	   1388	    132	 128695	  1f6b7	net/bluetooth/built-in.o.defconfig.old
> > 
> > $ size drivers/bluetooth/built-in.o*
> >  127575	   8976	  29476	 166027	  2888b	drivers/bluetooth/built-in.o.allyesconfig.new
> >  129512	   8976	  29516	 168004	  29044	drivers/bluetooth/built-in.o.allyesconfig.old
> >   52998	   3292	    156	  56446	   dc7e	drivers/bluetooth/built-in.o.defconfig.new
> >   54358	   3292	    156	  57806	   e1ce	drivers/bluetooth/built-in.o.defconfig.old
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >  include/net/bluetooth/bluetooth.h |   14 ++++++++------
> >  net/bluetooth/lib.c               |   27 ++++++++++++++++++++++++---
> >  2 files changed, 32 insertions(+), 9 deletions(-)
> 
> lets try to get at least this patch merged. I hope we don't have too
> many conflicts.
> 
> Acked-by: Marcel Holtmann <marcel@holtmann.org>

Applied to my bluetooth-next tree. Thanks.

Johan
