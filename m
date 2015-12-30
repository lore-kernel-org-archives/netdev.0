From: Doug Ledford <dledford@redhat.com>
Subject: Re: 4.4-rc7 failure report
Date: Tue, 29 Dec 2015 22:44:31 -0500
Message-ID: <5683531F.9000704@redhat.com>
References: <5681AF69.4040204@redhat.com> <5681B594.70304@iogearbox.net>
 <5681E154.7040101@redhat.com> <20151230034300.GA8670@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="78c0ILCx0bxq0wRt3KXkoutw16jlBMQVp"
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753987AbbL3Doc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Dec 2015 22:44:32 -0500
In-Reply-To: <20151230034300.GA8670@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--78c0ILCx0bxq0wRt3KXkoutw16jlBMQVp
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/29/2015 10:43 PM, Alexei Starovoitov wrote:
> On Mon, Dec 28, 2015 at 08:26:44PM -0500, Doug Ledford wrote:
>> On 12/28/2015 05:20 PM, Daniel Borkmann wrote:
>>> On 12/28/2015 10:53 PM, Doug Ledford wrote:
>>>> The 4.4-rc7 kernel is failing for me.  In my case, all of my vlan
>>>> interfaces are failing to obtain a dhcp address using dhclient.  I'v=
e
>>>> tried a hand built 4.4-rc7, and the Fedora rawhide 4.4-rc7 kernel, b=
oth
>>>> failed.  I've tried NetworkManager and the old SysV network service,=

>>>> both fail.  I tried a working dhclient from rhel7 on the Fedora rawh=
ide
>>>> install and it failed too.  Running tcpdump on the interface shows t=
he
>>>> dhcp request going out, and a dhcp response coming back in.  Running=

>>>> strace on dhclient shows that it writes the dhcp request, but it nev=
er
>>>> recvs a dhcp response.  If I manually bring the interface up with a
>>>> static IP address then I'm able to run typical IP traffic across the=

>>>> link (aka, ping).  It would seem that when dhclient registers a pack=
et
>>>> filter on the socket, that filter is preventing it from ever getting=
 the
>>>> dhcp response.  The same dhclient works on any non-vlan interfaces i=
n
>>>> the system, so the filter must work for non-vlan interfaces.  Aside =
from
>>>> the fact that the interface is a vlan, we also use a priority egress=
 map
>>>> on the interface, and we use PFC flow control.  Let me know if you n=
eed
>>>> anymore to debug the issue, or email me off list and I can get you
>>>> logins to my reproducer machines.
>>>
>>> When you say 4.4-rc7 kernel is failing for you, what latest kernel ve=
rsion
>>> was working, where the socket filter was properly receiving the respo=
nse on
>>> your vlan iface?
>>
>> v4.3 final works.  I haven't bisected where in the 4.4 series it quits=

>> working.  I can do that tomorrow.
>=20
> I've tried to reproduce, but cannot seem to make dnsmasq work properly
> over vlan, so bisect would be great.
>=20

Yeah, I've been working on it.  Issues with available machines that
reproduce combined with what hardware they have and whether or not that
hardware works at various steps in the bisection :-/

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--78c0ILCx0bxq0wRt3KXkoutw16jlBMQVp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWg1MfAAoJELgmozMOVy/dBfAQAJRK9ZnCtEFtetzV1CLSjQrC
aPqxbaGReaWr93mIVaOYKlUTFoPIh7FwNrnq0OT/l4xTC7ikgLdMmPYmtqScVk2J
WHelkKD9nVW1EZP6YGSpFRAfQXD9Sxa7/+aTtkblQOLqxGr45sYA7CDuk5azi9uO
Lg1Srn8mhaOiAB31cOMXzJtVxiuNBNdjMdnUsjbqV22+Jy5wChSYts92rSG8jhlp
dJLEJCt16AdmS6p8Yk3YOUgwcQ4OwyZAiehwGEPp3OgC93f4FYnqb98mgiliaoQ2
CgDlIe4eiiFo5k4ecmHERRS6TqjMr0UL5NjsyOuY3mdbB4VL4s+JmghI8+BwQ4tk
CuORYyz+lshWu5kYtwb4rLqiFkzNCPbHYukRMQVs9N+sO5rVqwtL9wD9j1xb+Coc
JrEtj5NxLfiRvahDSV0BRfL7Y1b9cyyoxxh5BY+bhAEBP45T3hdFqkFd7sbK3ztu
xLkV9507ucA361sxmMha/FdAgC9tUr2SIr88xtabgyFLFk728+hEKXIpNuWRQstM
tLp1Eg+nwgHcfanPQsBc0aGzS3AmfVsVasaLneMgnypHE14GU+kjEth9n65rAQ1u
QjTm/M0aF05XSLKuJeqUcgtWFpeUmOqFpLYPCNz28lctnd8GU+9b385FX+CeGYRe
0sKUS96RO4evGfoyfy4F
=fsM7
-----END PGP SIGNATURE-----

--78c0ILCx0bxq0wRt3KXkoutw16jlBMQVp--
