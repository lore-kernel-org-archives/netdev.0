From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the
 library
Date: Mon, 6 Feb 2017 23:46:16 +0100
Message-ID: <8352d0c2-1544-4f37-7937-875dab2c4297@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net>
 <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net>
 <5898CBEF.20201@iogearbox.net>
 <1136c1a4-1a73-a419-5550-4ebd8aee9d25@digikod.net>
 <5898FC39.90701@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="LKNSrWsIO6jxXV1jqUIQkxf8q1d4HFlcm"
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Shuah Khan <shuah@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5898FC39.90701@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LKNSrWsIO6jxXV1jqUIQkxf8q1d4HFlcm
Content-Type: multipart/mixed; boundary="wjGNGw1dHLD3C2ENSNaSpQuP1uD0X0CdJ";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Daniel Borkmann <daniel@iogearbox.net>, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
 Shuah Khan <shuah@kernel.org>
Message-ID: <8352d0c2-1544-4f37-7937-875dab2c4297@digikod.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the
 library
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net>
 <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net>
 <5898CBEF.20201@iogearbox.net>
 <1136c1a4-1a73-a419-5550-4ebd8aee9d25@digikod.net>
 <5898FC39.90701@iogearbox.net>
In-Reply-To: <5898FC39.90701@iogearbox.net>

--wjGNGw1dHLD3C2ENSNaSpQuP1uD0X0CdJ
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On 06/02/2017 23:44, Daniel Borkmann wrote:
> On 02/06/2017 10:30 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>> On 06/02/2017 20:18, Daniel Borkmann wrote:
>>> On 02/06/2017 08:16 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>>>> On 06/02/2017 16:30, Daniel Borkmann wrote:
>>>>> On 02/06/2017 12:14 AM, Micka=C3=ABl Sala=C3=BCn wrote:
>>>>>> Replace bpf_prog_load() with bpf_load_program() calls.
>>>>>>
>>>>>> Use the tools include directory instead of the installed one to al=
low
>>>>>> builds from other kernels.
>>>>>>
>>>>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>>>>>> Cc: Alexei Starovoitov <ast@fb.com>
>>>>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>>>> Cc: Shuah Khan <shuah@kernel.org>
>>>>>> ---
>>>>>>     tools/testing/selftests/bpf/Makefile        |  6 +++++-
>>>>>>     tools/testing/selftests/bpf/bpf_sys.h       | 21
>>>>>> ---------------------
>>>>>>     tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
>>>>>>     tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
>>>>>>     4 files changed, 14 insertions(+), 27 deletions(-)
>>>>>
>>>>> No objections, but if so, can't we add the remaining missing
>>>>> pieces to bpf lib, so we can remove bpf_sys.h altogether?
>>>>
>>>> OK, I'll send a new patch replacing bpf_sys.h entirely.
>>>
>>> Sounds great, thanks!
>>
>> Do you prefer a big patch or one for each replaced function?
>=20
> I think it makes sense to split it into two: i) this patch as-is
> for the prog part, and ii) rest for maps.
>=20

Hum, I already split them to ease the review. I'm going to send this
series now.


--wjGNGw1dHLD3C2ENSNaSpQuP1uD0X0CdJ--

--LKNSrWsIO6jxXV1jqUIQkxf8q1d4HFlcm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliY/LgACgkQIt7+33O9
apVbpQgAnGeAc3cAmuFJZMdRwmGS82BJxNpbbFSWYWfxFhUkADEYJLbCseNjGaZG
JIwfC6mOzA4Xe58f5p01d3735EWFJnItg2XSh1ZQuR6mEJGTHwrIsG5t/XtPAK6f
QOcAF+a3as2HgzBQkkb06GTI4ljSZ9f4a0X4PtLfqDRDd0guBxfGKfPLGnDs6DAH
Uq/qB2EmJ08QiQZyVzuqZz3ch/aWnFHIiIjPJ251hZQl4DFdFRnYolD8SF8VWONf
ECWQJnD8BgA8GGDel1isPNWm0kAZDg/3yrOpz+L4ImhuVPUb8TlBbcuQ1xpKVOm2
DNdxR2WqszTtaG3GjCOvbenG3JxEvQ==
=g3QG
-----END PGP SIGNATURE-----

--LKNSrWsIO6jxXV1jqUIQkxf8q1d4HFlcm--
