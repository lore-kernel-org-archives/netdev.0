From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Thu, 15 Dec 2016 11:28:06 -0500
Message-ID: <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="5i9l24ROn11cwRr5EvGBp6P6p23CEwhXJ"
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161215145212.GA29116-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--5i9l24ROn11cwRr5EvGBp6P6p23CEwhXJ
Content-Type: multipart/mixed; boundary="P18sTMLdepvQPcrmpVGCnlCaTd66Wott4";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
 Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Message-ID: <380b05bf-a18e-1f20-7e8e-10b61f77dec7-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 <20161215091226.GC811-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
 <20161215145212.GA29116-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>
In-Reply-To: <20161215145212.GA29116-W4f6Xiosr+yv7QzWx2u06xL4W9x8LtSr@public.gmane.org>

--P18sTMLdepvQPcrmpVGCnlCaTd66Wott4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/15/2016 9:52 AM, ira.weiny wrote:
> On Thu, Dec 15, 2016 at 11:12:26AM +0200, Leon Romanovsky wrote:
>> On Wed, Dec 14, 2016 at 11:59:32PM -0800, Vishwanathapura, Niranjana w=
rote:
>>> Thanks Jason for the valuable feedback.
>>> Here is the revised HFI VNIC patch series.
>>>
>>> ChangeLog:
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>> v1 =3D> v2:
>>> a) Removed hfi_vnic bus, instead make hfi_vnic driver an 'ib client',=

>>>    as per feedback from Jason Gunthorpe.
>>> b) Interface changes, data structure changes and variable name change=
s
>>>    associated with (a).
>>> c) Add hfi_ibdev abstraction to provide VNIC control operations to
>>>    hfi_vnic client.
>>> d) Minor fixes
>>> e) Moved hfi_vnic driver from .../sw/intel/vnic/hfi_vnic to
>>>    .../sw/intel/hfi_vnic.
>>
>> To put it into proportion, Jason asked you to do different thing.
>> http://marc.info/?l=3Dlinux-rdma&m=3D147977108302151&w=3D2
>> http://marc.info/?l=3Dlinux-rdma&m=3D148000415401842&w=3D2
>>
>> And Christoph,
>> http://marc.info/?l=3Dlinux-rdma&m=3D147985587425861&w=3D2
>=20
> Understood.  However, we never heard back from Niranjanas analysis of t=
he code
> which stated that > 60% of the code was dealing with the OPA MADs used =
to
> configure this device.
>=20
> https://www.spinics.net/lists/linux-rdma/msg43579.html
>=20
> Furthermore, neither Dave nor Doug has had time to weigh in on what we =
should
> do.
>=20
> So before we make that change we wanted to get consensus on using the
> hfi1_ibdev abstraction rather than the bus.  This was the _real_ techni=
cal
> change.
>=20
> Beyond that it is really just which maintainer wants this driver.  To t=
hat end
> I've also cc'ed Jeff Kirsher who maintains drivers/net/ethernet/intel. =
 Perhaps
> Dave would like the driver to go through that tree?
>=20
>=20
> I think there are pros and cons to both subtrees and in the end we will=
 do
> whatever is decided.
>=20
> For maintainer review:
>=20
> 	1) The driver encapsulates ethernet packets with OPA headers
>=20
> 	2) VNIC uses OPA management packets (MADs) for its configuration
>=20
> 	3) A significant portion (> 60% +) of the code is specific to OPA
>=20
> 		https://www.spinics.net/lists/linux-rdma/msg43579.html
>=20
> 	4) The driver is from Intel and we expect Intel to be the primary
> 	   contributor to the code.
>=20
> 	5) The driver, like hfi1, is dual licensed (GPL/BSD)
>=20
> 	6) Based on Christophs feedback we will be adding device capability
> 	   bits to the IB core to indicate HFI VNIC support.
>=20
> 		https://www.spinics.net/lists/linux-rdma/msg44113.html
>=20
>=20
> Doug, Dave, Jeff any thoughts?
>=20
> Ira
>=20

Sorry for my late reply.  The series is relatively large, and also
tagged with RFC, so it got shuffled to the back burner while I worked on
the stuff for this pull request.

I just read through the comments in the V1 series between Jason et. al.,
and my take on things is like this:

1) Since your intent is to make this work with multiple versions of the
hfi drivers, I disagree with Jason that just because there is only one
driver today that we should keep it simple.  Design it right from the
beginning of multi driver is your intent is, IMO, a better way to go.
You'll work out the bugs in the initial implementation and when it comes
time to add the second driver, things will go much more smoothly.

2) With more than 60% of the code being MAD related, and another
significant chunk being hfi related, and only a minor bit (20% maybe?)
being net related, I disagree that this belongs in the drivers/net or
net/ directories.  Part of the purpose of putting code like this in any
given directory is to group it with what it is most tightly tied too.
That way people doing sub-tree wide changes know the rough scope of
their work as the code that needs changed is grouped together.  Putting
this or IPoIB in one of the net trees would make it obvious to the
casual coder that these need changed for net changes, but would totally
hide the fact that once you tear into these drivers, there is a lot more
IB to them than there is net.  What's more, when 60+% of driver is
non-net, then you end up having many more of my patches crossing over
into Dave's tree than the opposite if you put the code under my tree.
If nothing else, locality of code churn would say both this and IPoIB
belong here despite them being net drivers.

3) I would like some hard reasons why this driver deserves to exist?
I'm struggling very hard right now with why we would add an entirely new
"encapsulate IP over RDMA" driver.  Even if you use regular Ethernet
MACs instead of IPoIB's 20byte MAC, I'm struggling for why IPoIB
couldn't be modified to know it supports two MAC sizes and provide
different net devices based on those different types?  I'm struggling to
see why IPoIB couldn't be modified to essentially have two transport
layers underneath?  I haven't done a thorough code review yet, but if I
get into the net driver portion of this and it has very much similarity
to the IPoIB net portion, I'm probably going to want answers about why
this can't be a modification of IPoIB to support multiple
transport/encapsulation types instead of a separate driver even more.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--P18sTMLdepvQPcrmpVGCnlCaTd66Wott4--

--5i9l24ROn11cwRr5EvGBp6P6p23CEwhXJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYUsScAAoJELgmozMOVy/dgnoP/R7xLJs36VF6qkiEdFTrmdTc
+mSiRHbrcPGppwb7N/AAYqz0WBoljm/97koFtQSIqP46gLpvc/PDSgTH6AkCOJSW
wjVofcXm2lXW6qsglSDBNjVeWyM+5Idm26jXEuIqV6kO+Y0kPtBxwhzUA54gRIEF
rCskhToo3OsGKw4o77qQTBmlQQddCP3kgB9/i41e0HplxRJmGbveA5580ymbGo4+
XqV0aL5T7cDK7MD9wnt8gULfRnClQg9ATUvW6r80XW1+XAnC9ScHEfSEKHGllvBN
PKi0PheBHEpItT3AIw0DHnrM8PoK6cpwKmXLFCzhsGUiD4pXP87WVrs5RuTZknko
tTAWTU2KUuoQ4hL+TZ4Uu2NVelmmykMUQIi4lOsaHpBQ6dJCHSqRSVMgsOV0anO3
siD9Nn7M2pRQ9h70gRnHyD1XL8Qdpb1u3+RG9I3dDVI8GuA8gR8PVO6XqBiByYqw
xMGlYYmBEkPgaTVjUpl8SknTj0BhIhQ2X44fGsjIkoRMeTrdp1GICUijvUc59fxI
WPpWi4ZAheKHlD4z9ltBGv1pePMtXi5eGFOpsWEYkD5YS7yfqFQnqkXaWGH7+gDK
iNvd9xzN5f//iF7VZIUeaucem4PaNJz1+XZEHJzpPJsNbtidpeJFTlsGhiUFA8JD
RgY2B3KapyWvM05P4Viv
=HWnQ
-----END PGP SIGNATURE-----

--5i9l24ROn11cwRr5EvGBp6P6p23CEwhXJ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
