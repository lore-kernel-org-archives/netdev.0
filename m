From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Thu, 19 Jan 2017 21:12:57 +0200
Message-ID: <20170119191257.GA28570@mtr-leonro.local>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
 <20170118183127.GC14198@obsidianresearch.com>
 <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9@sandisk.com>
 <20170119063326.GJ32481@mtr-leonro.local>
 <20170119180308.GD8109@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: Bart Van Assche <bart.vanassche@sandisk.com>,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33994 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754386AbdASTNK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 14:13:10 -0500
Content-Disposition: inline
In-Reply-To: <20170119180308.GD8109@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--huq684BweRXVnRxX
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 19, 2017 at 11:03:08AM -0700, Jason Gunthorpe wrote:
> On Thu, Jan 19, 2017 at 08:33:26AM +0200, Leon Romanovsky wrote:
> > On Wed, Jan 18, 2017 at 01:45:14PM -0800, Bart Van Assche wrote:
> > > On 01/18/2017 10:31 AM, Jason Gunthorpe wrote:
> > > > I think it depends on what this tool is supposed to cover, but based
> > > > on the description, I would start with netlink-only.
> > > >
> > > > The only place verbs covers a similar ground is in 'device
> > > > capabilities' - for some of that you might want to open a new-uAPI
> > > > verbs fd, but even the capability data from that would not be
> > > > totally offensive to be accessed over netlink.
> > > >
> > > > IMHO netlink should cover almost everything found in sysfs today.
> > >
> > > We would need a very strong argument to introduce a netlink API that
> > > duplicates existing sysfs API functionality. Since the sysfs API is
> > > extensible, why not extend that API further? E.g. the SCST sysfs API
> > > shows that more is possible with sysfs than what most kernel drivers
> > > realize.
> >
> > We didn't look deeply on sysfs mainly because it is unpopular
> > in netdev community. Maybe we were misled and it is simply not true.
>
> sysfs is unpopular because the 'one value per file' dogma is laregly
> unsuitable for complex mulit-value atomic changes which are common in
> netdev. You can force it to work, but it is pretty horrible..
>
> It is also very expensive if you want to shuttle a lot of data, eg I
> could not see doing something like 'netstat' for IB through sysfs
>
> Maybe you should start by showing some examples of command out you
> wish to have in a rdmatool ..

Ariel wrote very simplified version in his proposal:
Functionality
*************
The rdmatool will provide a platform which can grow as needed. The
initial functionality might include:
* help =E2=80=93 man page
* version =E2=80=93 version number
* statistics =E2=80=93 RDMA statistics =E2=80=93 such as port and QP statis=
tics
  	       To allow easy reading of statistics, we offer to use a filter
  	       functionality, allowing reading of statistics families, such
	       as link layer, error counters, etc.
* protocol =E2=80=93 RoCE/iWARP/InfiniBand related configuration, such as R=
DMA
	     congestion configuration and statistics
* query =E2=80=93 RDMA objects (qp, cq, srq, ..) information such as owner,
	  status, type
* debug =E2=80=93 an interface to allow read and write from user space
	  to the provider RDMA driver, exposing debug information.

Commands similar to "ip" program.

>
> Jason

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliBD7kACgkQ5GN7iDZy
WKcfQBAAhOJ8J2E3EOxI1nq16VQ9c4lr7fDHrqeMtSbwe5VdCvd7LdrwG5rX295r
i1u29Xo2x3er2kHXNkE9GSx/KElmUQFIyTcpiQZxSAF9YS9vmvjwnQ0FZYLrlgsW
TQPeR8eX69ZDzSeg6honq90EHqKFlmxjws0Z+7BEVpx5r47HdyQxzD3m4Le65EYt
xs8uIsz3wcwWgkLhGb1XlFCNp0nw6/2JMgaR++qcIQfQwy4uDs+2hIqZHV8557T5
CbiszIM4Jp15aMQPb0osK5Os4bimj8qL5S9BWPswgn7tL/mLhNfrWV1dfXvSUpsN
leUF17mlc4TGnKCameaz6SKSGJcUajjlntx/Y0PyPDKiugE/pivzcJUgks06ycaA
5NgwbfCXGQOHofKMG2wEIrMwL1wJoNTOnep21I09w/p/T7GhcmXh7aN6Anb3fn75
ZY+1hbioeKvpTmxCNC1I9btwUejrzaARQYSho/H38ELf1ve7BviYGK1eEtusQUsB
GGk/SG+3JycKUXkKW5lkfn71upJb2xN8xqi1bBXBCDEzTTHqQaWHISMlQCPSFGHV
5RDnnP/p+olgBIRFU1YKRBcn3d8O8oq7S+GZwDi01+ScmuU/FwfghcCeFq+Dv0UA
fzfSNU1DXjK2zuSJ9A/tqjUwcEQFvU7eW59wXPtDYoYOwh9xUv4=
=jqZR
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
