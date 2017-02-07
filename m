From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the akpm tree with the net-next
 tree
Date: Tue, 7 Feb 2017 20:45:36 +1100
Message-ID: <20170207204501.23ef9b12@canb.auug.org.au>
References: <20170207162322.3732a5a1@canb.auug.org.au>
        <4cbbbce4-1318-9a75-d918-5b209cc418e6@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4cbbbce4-1318-9a75-d918-5b209cc418e6@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On Tue, 7 Feb 2017 09:40:09 +0100 Marc Kleine-Budde <mkl@pengutronix.de> wrote:
>
> On 02/07/2017 06:23 AM, Stephen Rothwell wrote:
> > diff --cc drivers/net/can/flexcan.c
> > index ea57fed375c6,4dc71bce525c..000000000000
> > --- a/drivers/net/can/flexcan.c
> > +++ b/drivers/net/can/flexcan.c
> > @@@ -195,9 -189,7 +195,9 @@@
> >    */
> >   #define FLEXCAN_QUIRK_BROKEN_ERR_STATE	BIT(1) /* [TR]WRN_INT not connected */
> >   #define FLEXCAN_QUIRK_DISABLE_RXFG	BIT(2) /* Disable RX FIFO Global mask */
> >  -#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(3) /* Disable Memory error detection */
> >  +#define FLEXCAN_QUIRK_ENABLE_EACEN_RRS	BIT(3) /* Enable EACEN and RRS bit in ctrl2 */
> > - #define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disble Memory error detection */
> > ++#define FLEXCAN_QUIRK_DISABLE_MECR	BIT(4) /* Disbale Memory error detection */  
> 
>                                                   ^^^^^^^
> Should be "Disable". I'll send David Miller a fix for the typo.

The "Disbale" typo is only in my merge resolution :-(  I will fix it there.

-- 
Cheers,
Stephen Rothwell
