From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 1/25 v2] rdma/cm: define native IB address
Date: Mon, 27 Feb 2012 14:07:29 -0800
Message-ID: <CAL1RGDUu9sUbeWgBwivnAeXf+OWX_m5MRrizfzP4ni-FOGxiTQ@mail.gmail.com>
References: <Acy/UbLfE8J2OYoiRYW93MzjgJGL8Q==> <1828884A29C6694DAF28B7E6B8A8237325661ADD@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A8237325661ADD-P5GAC/sN6hlcIJlls4ac1rfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2011 at 1:44 PM, Hefty, Sean <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wro=
te:
> Define AF_IB and sockaddr_ib to allow the rdma_cm to use native IB
> addressing.
>
> Signed-off-by: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
> =A0include/linux/socket.h | =A0 =A02 +
> =A0include/rdma/ib.h =A0 =A0 =A0| =A0 89 ++++++++++++++++++++++++++++=
++++++++++++++++++++
> =A02 files changed, 91 insertions(+), 0 deletions(-)
> =A0create mode 100644 include/rdma/ib.h
>
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index d0e77f6..c2c7687 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -184,6 +184,7 @@ struct ucred {
> =A0#define AF_PPPOX =A0 =A0 =A0 24 =A0 =A0 =A0/* PPPoX sockets =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0#define AF_WANPIPE =A0 =A0 25 =A0 =A0 =A0/* Wanpipe API Sockets */
> =A0#define AF_LLC =A0 =A0 =A0 =A0 26 =A0 =A0 =A0/* Linux LLC =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> +#define AF_IB =A0 =A0 =A0 =A0 =A027 =A0 =A0 =A0/* Native InfiniBand =
address =A0 =A0*/
> =A0#define AF_CAN =A0 =A0 =A0 =A0 29 =A0 =A0 =A0/* Controller Area Ne=
twork =A0 =A0 =A0*/
> =A0#define AF_TIPC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A030 =A0 =A0 =A0/* TI=
PC sockets =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0#define AF_BLUETOOTH =A0 31 =A0 =A0 =A0/* Bluetooth sockets =A0 =A0=
 =A0 =A0 =A0 =A0*/
> @@ -227,6 +228,7 @@ struct ucred {
> =A0#define PF_PPPOX =A0 =A0 =A0 AF_PPPOX
> =A0#define PF_WANPIPE =A0 =A0 AF_WANPIPE
> =A0#define PF_LLC =A0 =A0 =A0 =A0 AF_LLC
> +#define PF_IB =A0 =A0 =A0 =A0 =A0AF_IB
> =A0#define PF_CAN =A0 =A0 =A0 =A0 AF_CAN
> =A0#define PF_TIPC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AF_TIPC
> =A0#define PF_BLUETOOTH =A0 AF_BLUETOOTH

Has this been run by the networking community?  Are they OK with this
assignment?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
