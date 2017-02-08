From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v3 04/11] bpf: Use bpf_load_program() from the
 library
Date: Wed, 8 Feb 2017 21:08:29 +0100
Message-ID: <c082fd66-aee7-f4dc-fb69-69462423062c@digikod.net>
References: <20170207214500.27496-1-mic@digikod.net>
 <20170207214500.27496-5-mic@digikod.net> <589A5597.7090107@fb.com>
 <20170208194657.GC2162@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="X5wOG7EJTiVF4NGrXcob43o2oddlrfjPG"
Cc: linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208194657.GC2162@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--X5wOG7EJTiVF4NGrXcob43o2oddlrfjPG
Content-Type: multipart/mixed; boundary="waT4poUNBwmF0TgqipnMGaGSjw4OFW8xn";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Arnaldo Carvalho de Melo <acme@redhat.com>,
 Alexei Starovoitov <ast@fb.com>
Cc: linux-kernel@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
 "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 Shuah Khan <shuah@kernel.org>
Message-ID: <c082fd66-aee7-f4dc-fb69-69462423062c@digikod.net>
Subject: Re: [PATCH net-next v3 04/11] bpf: Use bpf_load_program() from the
 library
References: <20170207214500.27496-1-mic@digikod.net>
 <20170207214500.27496-5-mic@digikod.net> <589A5597.7090107@fb.com>
 <20170208194657.GC2162@redhat.com>
In-Reply-To: <20170208194657.GC2162@redhat.com>

--waT4poUNBwmF0TgqipnMGaGSjw4OFW8xn
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable


On 08/02/2017 20:46, Arnaldo Carvalho de Melo wrote:
> Em Tue, Feb 07, 2017 at 03:17:43PM -0800, Alexei Starovoitov escreveu:
>> On 2/7/17 1:44 PM, Micka=EBl Sala=FCn wrote:
>>> -	union bpf_attr attr;
>>> +	union bpf_attr attr =3D {};
>>>
>>> -	bzero(&attr, sizeof(attr));
>>
>> I think somebody mentioned that there are compilers out there
>> that don't do it correctly, hence it was done with explicit bzero.
>> Arnaldo, Wang, do you remember the details?
>=20
> https://www.spinics.net/lists/netdev/msg411144.html
>=20
> But this was when some named initializers are used in a union with
> unnamed members like 'union bpf_attr', unsure if this would break with
> the above case where no named initializers are being used.
>=20
> Having that said, the above is gratuitous, the code that is being
> replaced is not related to the patch at hand, and conceptually the end
> result should be the same.
>=20
> So, please, just leave it as is, i.e. using bzero() and make your patch=

> a bit smaller, remember, small is good, smaller is even better ;-)
>=20
> - Arnaldo
>=20

Right, I'll do it.

Thanks


--waT4poUNBwmF0TgqipnMGaGSjw4OFW8xn--

--X5wOG7EJTiVF4NGrXcob43o2oddlrfjPG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliber0ACgkQIt7+33O9
apW58wf+IcqviHziqHE4sd64DTJOUZ/K65orjslCsiC35M3na3VQmnQ+f1B73NoY
emFbtQOssOJrGBOqk3ZpMAI8Iujdz/nFKeJxKx36btqHXDdGgDsl/l96prpyCVBZ
yBnP1HxdI4QgBZsCAFLoUnCKA1EQ3IIPXdPjx35/kMV5Jm0sRUMVx9WeSPK0wG61
2u5kVcmPmM4zXaPoNlU5AIB07Ua+wMJtPabVp7jVwVSlCKaxRwAbD6jvn4qhNRVI
zRhiworY/woEQKOfcFFY25L3X3qacBC3T7xFsk+Qj9skW7WAHG5Yes18BMKbh9sa
9iviZDCn5PIvwkATyP/Uk/9e/FX2zg==
=LIag
-----END PGP SIGNATURE-----

--X5wOG7EJTiVF4NGrXcob43o2oddlrfjPG--
