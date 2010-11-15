From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Mon, 15 Nov 2010 16:39:28 +0900
Message-ID: <000e01cb8498$3ec2cb80$66f8800a@maildom.okisemi.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>	<4CCAC4CD.7000503@pengutronix.de>
	<4CCAF517.2000409@pengutronix.de>	<4CCB213A.2020206@grandegger.com>
	<004a01cb825a$3a8bd060$66f8800a@maildom.okisemi.com>
	<4CDD28E6.9060006@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday, November 12, 2010 8:45 PM, Wolfgang Grandegger wrote:

> >> This is an enumeration:
> >>
> >> enum {
> >> PCH_STUF_ERR = 1,
> >> PCH_FORM_ERR,
> >> PCH_ACK_ERR,
> >> PCH_BIT1_ERR;
> >> PCH_BIT0_ERR,
> >> PCH_CRC_ERR,
> >> PCH_LEC_ALL;
> >> }
> > 
> > No, 
> > LEC is for bit assignment.
> > Thus, "enum" can't be used.
> 
> Why? For me it's a classical enum because the value matters, and *not*
> the individual bit. Do you agree?

Sorry, at last, I understand your saying.
I agree.



> >> Also, could you please add the TEC and REC:
> >>
> >> cf->data[6] = ioread32(&priv->regs->errc) & CAN_TEC;
> >> cf->data[7] = (ioread32(&priv->regs->errc) & CAN_REC) >> 8;
> > 
> > I will add.
> 
> BTW: it could be done with one I/O call:
> 
>   errc = ioread32(&priv->regs->errc);
>   cf->data[6] = errc & CAN_TEC;
>   cf->data[7] = (errc & CAN_REC) >> 8;
> 
> > But I couldn't find 
> 
> Don't understand? It's also implemented for the SJA1000 driver:

Sorry, the above my line is fogotten to delete.
I can uderstand your saying.

---
Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
