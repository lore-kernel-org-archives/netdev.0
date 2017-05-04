From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 4 May 2017 22:42:42 +0300
Message-ID: <20170504194242.GF22833@mtr-leonro.local>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
 <20170504182542.GD22833@mtr-leonro.local>
 <1493922625.2692.8.camel@sandisk.com>
 <20170504184531.GE22833@mtr-leonro.local>
 <2dee6cde-0406-b101-0fe6-c1f6de7c1b1a@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="TPGKQYD3WP7vMswh"
Cc: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org" <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org" <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <2dee6cde-0406-b101-0fe6-c1f6de7c1b1a-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--TPGKQYD3WP7vMswh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 04, 2017 at 03:26:13PM -0400, Dennis Dalessandro wrote:
> On 05/04/2017 02:45 PM, Leon Romanovsky wrote:
> > On Thu, May 04, 2017 at 06:30:27PM +0000, Bart Van Assche wrote:
> > > On Thu, 2017-05-04 at 21:25 +0300, Leon Romanovsky wrote:
> > > > On Thu, May 04, 2017 at 06:10:54PM +0000, Bart Van Assche wrote:
> > > > > On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > > > > > Following our discussion both in mailing list [1] and at the LPC 2016 [2],
> > > > > > we would like to propose this RDMA tool to be part of iproute2 package
> > > > > > and finally improve this situation.
> > > > >
> > > > > Hello Leon,
> > > > >
> > > > > Although I really appreciate your work: can you clarify why you would like to
> > > > > add *RDMA* functionality to an *IP routing* tool? I haven't found any motivation
> > > > > for adding RDMA functionality to iproute2 in [1].
> > > >
> > > > We are planning to reuse the same infrastructure provided by iproute2,
> > > > like netlink parsing, access to distributions, same CLI and same standards.
> > > >
> > > > Right now, RDMA is already tightened to netdev: iWARP, RoCE, IPoIB, HFI-VNIC.
> > > > Many drivers (mlx, qed, i40, cxgb) are sharing code between net and
> > > > RDMA.
> > > >
> > > > I do expect that iproute2 will be installed on every machine with any
> > > > type of connection, including IB and OPA.
> > > >
> > > > So I think that it is enough to be part of that suite and don't invent
> > > > our own for one specific tool.
> > >
> > > Hello Leon,
> > >
> > > Sorry but to me that sounds like a weak argument for including RDMA functionality
> > > in iproute2. There is already a library for communication over netlink sockets,
> > > namely libnl. Is there functionality that is in iproute2 but not in libnl and
> > > that is needed for the new tool? If so, have you considered to create a new
> > > library for that functionality?
> >
> > It is not hard to create new tool, the hardest part is to ensure that it is
> > part of the distributions. Did you count how many months we are trying to
> > add rdma-core to debian?
>
> I do agree that it is a strange pairing and am not really a fan. However at
> the end of the day it's just a name for a repo/package. If the iproute folks
> are fine to include rdma in their repo/package, great we can leverage their
> code for CLI and other common stuff.
>
> Now if the interface was something like "ip -FlagForRdma ..." I would object
> to that, but the interface is "rdma ... " so from users perspective it's
> different tools. They don't need to care that it was sourced from a common
> git repo.
>
> Just as an aside this already works a bit with OPA:
>
>  $ ./rdma link
> 1/1: hfi1_0/1: ifname NONE cap_mask 0x00410022 lid 0x1 lid_mask_count 0
> link_layer InfiniBand
>          phys_state 5: LinkUp rate 100 Gb/sec (4X EDR) sm_lid 0x1 sm_sl 0
> state 4: ACTIVE
>
> Leon I'll get you more feedback and testing, I've just been really bogged
> down this week, sorry.

Thanks Denny,

Before you are starting to test it, can you please provide your feedback
on my initial questions? Usability and need of sysfs.

----
This is initial phase to understand if user experience for this tool fits
RDMA and netdev communities exepectations. Also I would like to get feedback
if it is really worth to provide legacy sysfs for old kernels, or maybe I should
implement netlink from the beginning and abandon sysfs completely.
-----

P.S. I believe this will give you wrong output, because it parses IB port cap_mask.
$./rdma link show hfi1_0/1 cap_mask

Thanks

>
> -Denny
>
>
>

--TPGKQYD3WP7vMswh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkLhDEACgkQ5GN7iDZy
WKeeYA//TGXXzyV70wSdFdNSi1Sb9jZdZoustfngkIfov0kPdLpT11mvZlevr8mp
yuYPyGCPu6LAkohlNMQvkyVPllE8LnN8JqtA2BnJ1orkY7Ft7T1IZZPVKqqGG2py
O3ofJ8Lq6nKPXLbTYLDrvDoRHpUxaW7eL6VsjmaYKqcDW8Q8g64rCx99fxk6CMIH
E32zcEgKWhuK7KqOS5PXtOFCjfOu9NSHgBlQKTe6WnBwGjuaxS9s6m6WoHaKV0tm
JQNq/ZIJv9CJJhdsJ5/BuOOgICUKRdMREla7fL4AwIuQY9OxyV2P/8u/MOIUYQ4t
bDDd7aJ9sacI8sSo4IxWS4gye9XrDjQIWGWd4i0egfS7/dd+aP5o+8FcfYoVAGiz
3wimddUOBKxm30Tf51sMBr/WyTXQ/Pi/XEY45r08zDimJm63b2Ejl8BajuH7U00B
pfpIJI+yIaBvpMZSAwp9VC67DCGE9Rm3kJy0EP9+COnhohbocTw281BB2FNeO5Cp
zKyB/GUvWtQ0GzE7sBoPJl+3dnzExPK6/8+EWB/l4PD4rNHqTzvVNKzAnQo4zGZD
HrFzTQnbX1+ttZ80ZsbLu/OmMZ/0DWAtFKlhyfeVQ0t3/IwDUZASZLvC4cy3nThF
Rw2DugcAveMvLKqhs3GTc3UdpXaY4DwyCtpMUUz+/1KHJMpKPWU=
=3pzw
-----END PGP SIGNATURE-----

--TPGKQYD3WP7vMswh--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
