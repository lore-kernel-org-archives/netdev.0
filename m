From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 4 May 2017 21:45:31 +0300
Message-ID: <20170504184531.GE22833@mtr-leonro.local>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
 <20170504182542.GD22833@mtr-leonro.local>
 <1493922625.2692.8.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="GMArzDD+OGn24EFp"
Cc: "jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org" <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org" <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org" <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        "stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1493922625.2692.8.camel-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--GMArzDD+OGn24EFp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 04, 2017 at 06:30:27PM +0000, Bart Van Assche wrote:
> On Thu, 2017-05-04 at 21:25 +0300, Leon Romanovsky wrote:
> > On Thu, May 04, 2017 at 06:10:54PM +0000, Bart Van Assche wrote:
> > > On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > > > Following our discussion both in mailing list [1] and at the LPC 2016 [2],
> > > > we would like to propose this RDMA tool to be part of iproute2 package
> > > > and finally improve this situation.
> > >
> > > Hello Leon,
> > >
> > > Although I really appreciate your work: can you clarify why you would like to
> > > add *RDMA* functionality to an *IP routing* tool? I haven't found any motivation
> > > for adding RDMA functionality to iproute2 in [1].
> >
> > We are planning to reuse the same infrastructure provided by iproute2,
> > like netlink parsing, access to distributions, same CLI and same standards.
> >
> > Right now, RDMA is already tightened to netdev: iWARP, RoCE, IPoIB, HFI-VNIC.
> > Many drivers (mlx, qed, i40, cxgb) are sharing code between net and
> > RDMA.
> >
> > I do expect that iproute2 will be installed on every machine with any
> > type of connection, including IB and OPA.
> >
> > So I think that it is enough to be part of that suite and don't invent
> > our own for one specific tool.
>
> Hello Leon,
>
> Sorry but to me that sounds like a weak argument for including RDMA functionality
> in iproute2. There is already a library for communication over netlink sockets,
> namely libnl. Is there functionality that is in iproute2 but not in libnl and
> that is needed for the new tool? If so, have you considered to create a new
> library for that functionality?

It is not hard to create new tool, the hardest part is to ensure that it is
part of the distributions. Did you count how many months we are trying to
add rdma-core to debian?

I have enough headache with that and don't want another one.

Do you have situation in mind where you will have RDMA device without
iproute2 installed?

Thanks

>
> Thanks,
>
> Bart.

--GMArzDD+OGn24EFp
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkLdssACgkQ5GN7iDZy
WKfZtA/+KVhmZtieObVxZhm7rjMtXoxtLbtSbqRCX5EIri54RK5XVDMYYjNyoqrK
6bnoEvA0Z0PLCqDesyhqJGWkbJ7ZYlfGhR1jB3k0B6pKv+zqCdAVR3B+UQcZEqly
+h7FO1B8FdAbC8oKufDJPQuZzmj0NO6S9PG6OBM9yxSc94x8ZY+gAI4ybcekXvVL
+ncP4YAxjLqzL8BENh/cewzfPDEPUmSi1znHI2FyP2k7n8HSuiof2faTU1+tptkI
sqZTLqrGwAITL9kp344TzMDvO0OPysEh6kEkiIX4x4LgTza8HSx2IxvRBnU31Rns
kKyBmm4E4fz5qfxMR2D3lEHB0QsxTItqq9EWvUhgo/IFtG7L32HiRYmTiCrTDP71
lYynOdqPlPT0Y7CHL9VlTlF+gRgoVT2kZi/olCfO1rKdTMlg53tnU/pAs8YBOy3Y
9eaVMRptxKD6lbvA2qaMYBunB5EI0bemwCCr5k7jvySQdOWuZmOcPkvxhpl6Gbgi
EI+4JvQTAFbd+1/9VuWjoE+gdutQEuNDeGOIWQAncRtqRJt2aiE/N+7GyJniEhmI
HC9bdNOhMGla2ssBfERJGbdXDHUXH9g1Z0umT/Ye8VQjHKeL9aMsKjsirinwF/7x
cwtxNS28Nb2BYyoaRWdKHH08tWnDRmUX3y+GEMeGs7jnWSTKRP0=
=f6hf
-----END PGP SIGNATURE-----

--GMArzDD+OGn24EFp--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
