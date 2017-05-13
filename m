From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH v1] samples/bpf: Add a .gitignore for binaries
Date: Sat, 13 May 2017 12:30:42 +0200
Message-ID: <bd91cc8d-4683-4c4c-e672-7dce5da28183@digikod.net>
References: <20170212212356.11675-1-mic@digikod.net>
 <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="kK6jomDRCk60X1dmHtPP3er9uwx3eTDNA"
Cc: linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--kK6jomDRCk60X1dmHtPP3er9uwx3eTDNA
Content-Type: multipart/mixed; boundary="bEU9SXhssKp0EXPVPNMkLwN2xIVqaMjmx";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: David Ahern <dsa@cumulusnetworks.com>, Alexei Starovoitov <ast@fb.com>,
 Daniel Borkmann <daniel@iogearbox.net>
Cc: linux-kernel@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
 Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
Message-ID: <bd91cc8d-4683-4c4c-e672-7dce5da28183@digikod.net>
Subject: Re: [PATCH v1] samples/bpf: Add a .gitignore for binaries
References: <20170212212356.11675-1-mic@digikod.net>
 <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
In-Reply-To: <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>

--bEU9SXhssKp0EXPVPNMkLwN2xIVqaMjmx
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 13/02/2017 02:43, David Ahern wrote:
> On 2/12/17 2:23 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>> diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
>> new file mode 100644
>> index 000000000000..a7562a5ef4c2
>> --- /dev/null
>> +++ b/samples/bpf/.gitignore
>> @@ -0,0 +1,32 @@
>> +fds_example
>> +lathist
>=20
> ...
>=20
> Listing each target is going to be a PITA to maintain. It would be
> better to put targets into a build directory (bin?) and ignore the
> directory.
>=20

It would require a lot of modifications to the Makefile and more
complexity. It seems much more simple for everyone to stick to a simple
gitignore file easily maintainable:
$ awk '$1 =3D=3D "hostprogs-y" { print $3 }' < Makefile > .gitignore

Alexei, Daniel, what do you think about this? Do you want me to send a
v2 with the new tests?

 Micka=C3=ABl


--bEU9SXhssKp0EXPVPNMkLwN2xIVqaMjmx--

--kK6jomDRCk60X1dmHtPP3er9uwx3eTDNA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlkW4FIACgkQIt7+33O9
apWFcgf9HXzmOQqa1RXwezh2SyBfaXPg0e7KIwLCXLao9cR/PomiXfPpY3OLQcIc
fulE5kT6dlov1wVXBLwjXVqWECFjCNrVRYcAc/IwQlN2TPXCUSig29avwBuiQ1mG
jVmxBV6heSUnAc52Uk8p9ucp2dckqsTX/r3Br2Uwu2/B7l6VVfKk0FyUYS8dvMSE
sYrS7R/cD1KPQxyrvYJMP13GV7bgPmsLX5tN1jbsjZZVYLVnbN8dVwyR7hB+vKOI
aSt6pryo2ihNtZB6jyVEXaWq8x05BHK9GA6gZIwmOq/MsJhpyYTrA+315SNtAWNC
SLe5/UsQ/Mqz97bjuRuNjgv8A8sHXQ==
=nGMn
-----END PGP SIGNATURE-----

--kK6jomDRCk60X1dmHtPP3er9uwx3eTDNA--
