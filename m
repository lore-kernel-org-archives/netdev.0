From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Thu, 19 Jan 2017 08:33:26 +0200
Message-ID: <20170119063326.GJ32481@mtr-leonro.local>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
 <20170118183127.GC14198@obsidianresearch.com>
 <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9@sandisk.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="cpgGT4jyFUyD7BZ9"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Ariel Almog <arielalmogworkemails-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bart Van Assche <bart.vanassche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--cpgGT4jyFUyD7BZ9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jan 18, 2017 at 01:45:14PM -0800, Bart Van Assche wrote:
> On 01/18/2017 10:31 AM, Jason Gunthorpe wrote:
> > I think it depends on what this tool is supposed to cover, but based
> > on the description, I would start with netlink-only.
> >
> > The only place verbs covers a similar ground is in 'device
> > capabilities' - for some of that you might want to open a new-uAPI
> > verbs fd, but even the capability data from that would not be
> > totally offensive to be accessed over netlink.
> >
> > IMHO netlink should cover almost everything found in sysfs today.
>
> We would need a very strong argument to introduce a netlink API that
> duplicates existing sysfs API functionality. Since the sysfs API is
> extensible, why not extend that API further? E.g. the SCST sysfs API
> shows that more is possible with sysfs than what most kernel drivers
> realize.

We didn't look deeply on sysfs mainly because it is unpopular
in netdev community. Maybe we were misled and it is simply not true.

>
> Bart.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--cpgGT4jyFUyD7BZ9
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliAXbYACgkQ5GN7iDZy
WKdVMg//VmBObdkGkBGsU/JabpK3FKZDJFLrSTs+83NSmEqeMQtO1RUFK08RD/v5
ZZAA/CGvtDpjE3Rr3uhP94c9vdQionj3KvsihGD6EJ7Krl4sX3eyULWp9OdQZNqO
BSiKvyAoTMu0PtMMLK5TSqERynZHhLWSmADbczGN9U3YIWcQjrbL2KF2tnFLJIHa
74zA9WKWiZ7a7tG/2iKl+QeUrbHoT8Azlxw3Pt6y+gosxjyUVa9AmK5T1jtn3OcW
yKTP3AD8mOAI9LToynu7yPnhkCzvkB4RHqEC7FUSjrbFayyp1r1qls7AtDKZWhc9
Ho4vCUMtuukloxHg2M1pIPNW76njiqN9M54WnN1660I7B+NXMXllkfHzlN6wFTbr
MIH3pEd6A08vLREooawMdeyUAk/WeNPuGc7MKPcBJNEHvvFXmEFZ6TZX52wsjdZu
WUdD8JiY+H0V15nXpYvWl2C/IrsIgkBnzXqWLkrrXePbWnH/b++ZoXj/wFw3MTyO
JItLKNZR0qCRW3X1ZqzCpJzSNIzqVKZWUnXHrroPRrExUtAG2nFzXd7oiX0j5e6t
oXdsF7P0KhZi94NWTVvqlqMQJPj+IzCANgIDcMWFFv2X5EvOD0vv0WmvnNgE0KwT
kRobGRmlirNBXITNFY7Rr2HIGUQaWyzLemQZx37cL9oA2mxHCPw=
=e7J4
-----END PGP SIGNATURE-----

--cpgGT4jyFUyD7BZ9--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
