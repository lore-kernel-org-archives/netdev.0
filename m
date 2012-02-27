From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [PATCH 1/25 v2] rdma/cm: define native IB address
Date: Mon, 27 Feb 2012 22:22:31 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373374F1A64@ORSMSX102.amr.corp.intel.com>
References: <Acy/UbLfE8J2OYoiRYW93MzjgJGL8Q==>
 <1828884A29C6694DAF28B7E6B8A8237325661ADD@ORSMSX102.amr.corp.intel.com>
 <CAL1RGDUu9sUbeWgBwivnAeXf+OWX_m5MRrizfzP4ni-FOGxiTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDUu9sUbeWgBwivnAeXf+OWX_m5MRrizfzP4ni-FOGxiTQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > diff --git a/include/linux/socket.h b/include/linux/socket.h
> > index d0e77f6..c2c7687 100644
> > --- a/include/linux/socket.h
> > +++ b/include/linux/socket.h
> > @@ -184,6 +184,7 @@ struct ucred {
> > =A0#define AF_PPPOX =A0 =A0 =A0 24 =A0 =A0 =A0/* PPPoX sockets =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > =A0#define AF_WANPIPE =A0 =A0 25 =A0 =A0 =A0/* Wanpipe API Sockets =
*/
> > =A0#define AF_LLC =A0 =A0 =A0 =A0 26 =A0 =A0 =A0/* Linux LLC =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> > +#define AF_IB =A0 =A0 =A0 =A0 =A027 =A0 =A0 =A0/* Native InfiniBan=
d address =A0 =A0*/
> > =A0#define AF_CAN =A0 =A0 =A0 =A0 29 =A0 =A0 =A0/* Controller Area =
Network =A0 =A0 =A0*/
> > =A0#define AF_TIPC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A030 =A0 =A0 =A0/* =
TIPC sockets =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> > =A0#define AF_BLUETOOTH =A0 31 =A0 =A0 =A0/* Bluetooth sockets =A0 =
=A0 =A0 =A0 =A0 =A0*/
> > @@ -227,6 +228,7 @@ struct ucred {
> > =A0#define PF_PPPOX =A0 =A0 =A0 AF_PPPOX
> > =A0#define PF_WANPIPE =A0 =A0 AF_WANPIPE
> > =A0#define PF_LLC =A0 =A0 =A0 =A0 AF_LLC
> > +#define PF_IB =A0 =A0 =A0 =A0 =A0AF_IB
> > =A0#define PF_CAN =A0 =A0 =A0 =A0 AF_CAN
> > =A0#define PF_TIPC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AF_TIPC
> > =A0#define PF_BLUETOOTH =A0 AF_BLUETOOTH
>=20
> Has this been run by the networking community?  Are they OK with this
> assignment?

I did copy netdev on the original submissions, but I don't remember any=
 explicit ack or nack.

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
