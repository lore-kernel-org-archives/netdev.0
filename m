From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 1/2] 8139too: clean up spaces and TABs
Date: Sat, 14 Jun 2008 23:21:34 +0200
Message-ID: <200806142321.37180.linux@rainbow-software.org>
References: <4853BB62.1060109@freemail.hu> <48541165.7050304@freemail.hu> <485421C1.8010102@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?q?N=E9meth_M=E1rton?= <nm127@freemail.hu>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atlantis.sk ([80.94.52.35]:38831 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756706AbYFNVVq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:21:46 -0400
In-Reply-To: <485421C1.8010102@s5r6.in-berlin.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 14 June 2008 21:53:37 Stefan Richter wrote:
> N=E9meth M=E1rton wrote:
> > From: M=E1rton N=E9meth <nm127@freemail.hu>
> >
> > Clean up the following errors and warnings reported by checkpatch.p=
l:
>
> Is 8139too in active development or are there people actively fixing
> current bugs in it?  If not, a whitespace cleanup may be considered a
> waste of time.  There are even a few valid arguments that such change=
s
> are harmful then.

A more useful thing would be to merge 8139too and 8139cp drivers togeth=
er so=20
user can just put RTL8139 card in the box and it will work. The current=
 state=20
is completely broken - two drivers for two versions of the chip which h=
ave=20
the same PCI IDs.

>
> >  - space prohibited between function name and open parenthesis '('
> >  - space required before the open brace '{'
> >  - code indent should use tabs where possible
> >  - line over 80 characters
> >  - spaces required around that '=3D' (ctx:VxW)
>
> Did you check that your whitespace changes are indeed only whitespace
> changes, i.e. that resulting assembler is unchanged?  If you checked =
it,
> it's worth mentioning in the submission.
>
> > Signed-off-by: M=E1rton N=E9meth <nm127@freemail.hu>
> > ---
> > --- a/drivers/net/8139too.c	2008-06-14 00:20:47.000000000 +0200
> > +++ b/drivers/net/8139too.c	2008-06-14 20:32:45.000000000 +0200
> > @@ -11,7 +11,7 @@
> >
> >  	-----<snip>-----
> >
> > -        	Written 1997-2001 by Donald Becker.
> > +		Written 1997-2001 by Donald Becker.
> >  		This software may be used and distributed according to the
> >  		terms of the GNU General Public License (GPL), incorporated
> >  		herein by reference.  Drivers based on or derived from this
>
> This is not the canonical multi-line comment style.
>
> > @@ -116,8 +116,8 @@
> >
> >  /* Default Message level */
> >  #define RTL8139_DEF_MSG_ENABLE   (NETIF_MSG_DRV   | \
> > -                                 NETIF_MSG_PROBE  | \
> > -                                 NETIF_MSG_LINK)
> > +				  NETIF_MSG_PROBE | \
> > +				  NETIF_MSG_LINK)
>
> Why change this?
>
> (Besides for the reason that checkpatch says that new patches /should=
/
> use tabs at such occasions, which also isn't universally agreed upon.=
)
>
> >  /* enable PIO instead of MMIO, if CONFIG_8139TOO_PIO is selected *=
/
> > @@ -134,7 +134,8 @@
> >
> >  #if RTL8139_DEBUG
> >  /* note: prints function name for you */
> > -#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt,
> > __FUNCTION__ , ## args) +#  define DPRINTK(fmt, args...) \
> > +	printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
> >  #else
> >  #  define DPRINTK(fmt, args...)
> >  #endif
>
> This line is merely 6 characters too long and does not contain anythi=
ng
> particularly important.  Why bother?
>
> > @@ -143,10 +144,10 @@
> >  #  define assert(expr) do {} while (0)
> >  #else
> >  #  define assert(expr) \
> > -        if(unlikely(!(expr))) {				        \
> > -        printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	=
\
> > -        #expr,__FILE__,__FUNCTION__,__LINE__);		        \
> > -        }
> > +	if (unlikely(!(expr))) {					\
> > +		printk(KERN_ERR "Assertion failed! %s,%s,%s,line=3D%d\n",	\
> > +		       #expr, __FILE__, __FUNCTION__, __LINE__);	\
> > +	}
> >  #endif
> >
> >
> > @@ -196,7 +197,9 @@ static int debug =3D -1;
> >     Threshold is bytes transferred to chip before transmission star=
ts. */
> >  #define TX_FIFO_THRESH 256	/* In bytes, rounded down to 32 byte un=
its.
> > */
> >
> > -/* The following settings are log_2(bytes)-4:  0 =3D=3D 16 bytes .=
=2E 6=3D=3D1024,
> > 7=3D=3Dend of packet. */ +/* The following settings are log_2(bytes=
)-4:
> > + * 0 =3D=3D 16 bytes .. 6=3D=3D1024, 7=3D=3Dend of packet.
> > + */
> >  #define RX_FIFO_THRESH	7	/* Rx buffer level before first PCI xfer.=
  */
> >  #define RX_DMA_BURST	7	/* Maximum PCI burst, '6' is 1024 */
> >  #define TX_DMA_BURST	6	/* Maximum PCI burst, '6' is 1024 */
>
> This is not Linux multi-line comment style.  (It comes close to the
> present style of 8139too.c though and may therefore be acceptable.)
>
> [...]
>
> > @@ -1253,57 +1280,59 @@ static int mdio_read (struct net_device
> >  }
> >
> >
> > -static void mdio_write (struct net_device *dev, int phy_id, int
> > location, -			int value)
> > +static void mdio_write(struct net_device *dev, int phy_id, int loc=
ation,
> > +		       int value)
> >  {
> >  	struct rtl8139_private *tp =3D netdev_priv(dev);
> >  #ifdef CONFIG_8139TOO_8129
> >  	void __iomem *ioaddr =3D tp->mmio_addr;
> > -	int mii_cmd =3D (0x5002 << 16) | (phy_id << 23) | (location << 18=
) |
> > value; +	int mii_cmd =3D (0x5002 << 16) | (phy_id << 23) | (locatio=
n << 18)
> > | +		      value;
> >  	int i;
>
> This decreases readability.  You could leave this merely 81 columns l=
ong
> line as is.  Or remove the superfluous parentheses.
>
> [...]
>
> > @@ -1945,22 +1978,22 @@ static int rtl8139_rx(struct net_device
> >  		rmb();
> >
> >  		/* read size+status of next frame from DMA ring buffer */
> > -		rx_status =3D le32_to_cpu (*(__le32 *) (rx_ring + ring_offset));
> > +		rx_status =3D le32_to_cpu(*(__le32 *) (rx_ring + ring_offset));
> >  		rx_size =3D rx_status >> 16;
> >  		pkt_size =3D rx_size - 4;
> >
> >  		if (netif_msg_rx_status(tp))
> > -			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, size %4.4x,"
> > -				" cur %4.4x.\n", dev->name, rx_status,
> > -			 rx_size, cur_rx);
> > +			printk(KERN_DEBUG "%s:  rtl8139_rx() status %4.4x, "
> > +			       "size %4.4x, cur %4.4x.\n",
> > +			       dev->name, rx_status, rx_size, cur_rx);
> >  #if RTL8139_DEBUG > 2
> >  		{
> >  			int i;
> > -			DPRINTK ("%s: Frame contents ", dev->name);
> > +			DPRINTK("%s: Frame contents ", dev->name);
> >  			for (i =3D 0; i < 70; i++)
> > -				printk (" %2.2x",
> > -					rx_ring[ring_offset + i]);
> > -			printk (".\n");
> > +				printk(" %2.2x",
> > +				       rx_ring[ring_offset + i]);
> > +			printk(".\n");
> >  		}
> >  #endif
>
> This printk trick does not work BTW.  But it should of course not be
> fixed in a patch which is meant to be a whitespace change only.
>
> [...]



--=20
Ondrej Zary
