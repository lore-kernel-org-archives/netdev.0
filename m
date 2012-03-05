From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 1/25 v2] rdma/cm: define native IB address
Date: Mon, 5 Mar 2012 12:34:17 -0800
Message-ID: <CAL1RGDV-oYkNwQQUkAuUEHTH=HbmLk6Kv7JRnJ3XxN1DMNzLNQ@mail.gmail.com>
References: <1828884A29C6694DAF28B7E6B8A8237325661ADD@ORSMSX102.amr.corp.intel.com>
 <CAL1RGDUu9sUbeWgBwivnAeXf+OWX_m5MRrizfzP4ni-FOGxiTQ@mail.gmail.com> <1828884A29C6694DAF28B7E6B8A82373374F1A64@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373374F1A64-P5GAC/sN6hlcIJlls4ac1rfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 2:22 PM, Hefty, Sean <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wro=
te:
>> > --- a/include/linux/socket.h
>> > +++ b/include/linux/socket.h
>> > @@ -184,6 +184,7 @@ struct ucred {
>> > =A0#define AF_PPPOX =A0 =A0 =A0 24 =A0 =A0 =A0/* PPPoX sockets =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > =A0#define AF_WANPIPE =A0 =A0 25 =A0 =A0 =A0/* Wanpipe API Sockets=
 */
>> > =A0#define AF_LLC =A0 =A0 =A0 =A0 26 =A0 =A0 =A0/* Linux LLC =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > +#define AF_IB =A0 =A0 =A0 =A0 =A027 =A0 =A0 =A0/* Native InfiniBa=
nd address =A0 =A0*/
>> > =A0#define AF_CAN =A0 =A0 =A0 =A0 29 =A0 =A0 =A0/* Controller Area=
 Network =A0 =A0 =A0*/
>> > =A0#define AF_TIPC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A030 =A0 =A0 =A0/*=
 TIPC sockets =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> > =A0#define AF_BLUETOOTH =A0 31 =A0 =A0 =A0/* Bluetooth sockets =A0=
 =A0 =A0 =A0 =A0 =A0*/
>> > @@ -227,6 +228,7 @@ struct ucred {
>> > =A0#define PF_PPPOX =A0 =A0 =A0 AF_PPPOX
>> > =A0#define PF_WANPIPE =A0 =A0 AF_WANPIPE
>> > =A0#define PF_LLC =A0 =A0 =A0 =A0 AF_LLC
>> > +#define PF_IB =A0 =A0 =A0 =A0 =A0AF_IB
>> > =A0#define PF_CAN =A0 =A0 =A0 =A0 AF_CAN
>> > =A0#define PF_TIPC =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AF_TIPC
>> > =A0#define PF_BLUETOOTH =A0 AF_BLUETOOTH
>>
>> Has this been run by the networking community? =A0Are they OK with t=
his
>> assignment?
>
> I did copy netdev on the original submissions, but I don't remember a=
ny explicit ack or nack.

David, any feeling yay or nay about adding these?

Is the kernel the final arbiter of AF_xxx / PF_xxx assignments, or
is there anything else we have to worry about?

Thanks,
  Roland
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
