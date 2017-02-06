From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the
 library
Date: Mon, 6 Feb 2017 22:30:18 +0100
Message-ID: <1136c1a4-1a73-a419-5550-4ebd8aee9d25@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net>
 <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net>
 <5898CBEF.20201@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="Otd08lEItf39hhpdDRwfhScQEKaFjurWd"
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Shuah Khan <shuah@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5898CBEF.20201@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Otd08lEItf39hhpdDRwfhScQEKaFjurWd
Content-Type: multipart/mixed; boundary="bQawRxMqnpDhQ2D5UBPBao38K7DgTCgrV";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Daniel Borkmann <daniel@iogearbox.net>, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
 Shuah Khan <shuah@kernel.org>
Message-ID: <1136c1a4-1a73-a419-5550-4ebd8aee9d25@digikod.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the
 library
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net>
 <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net>
 <5898CBEF.20201@iogearbox.net>
In-Reply-To: <5898CBEF.20201@iogearbox.net>

--bQawRxMqnpDhQ2D5UBPBao38K7DgTCgrV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 06/02/2017 20:18, Daniel Borkmann wrote:
> On 02/06/2017 08:16 PM, Micka=C3=ABl Sala=C3=BCn wrote:
>> On 06/02/2017 16:30, Daniel Borkmann wrote:
>>> On 02/06/2017 12:14 AM, Micka=C3=ABl Sala=C3=BCn wrote:
>>>> Replace bpf_prog_load() with bpf_load_program() calls.
>>>>
>>>> Use the tools include directory instead of the installed one to allo=
w
>>>> builds from other kernels.
>>>>
>>>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>>>> Cc: Alexei Starovoitov <ast@fb.com>
>>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>> Cc: Shuah Khan <shuah@kernel.org>
>>>> ---
>>>>    tools/testing/selftests/bpf/Makefile        |  6 +++++-
>>>>    tools/testing/selftests/bpf/bpf_sys.h       | 21
>>>> ---------------------
>>>>    tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
>>>>    tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
>>>>    4 files changed, 14 insertions(+), 27 deletions(-)
>>>
>>> No objections, but if so, can't we add the remaining missing
>>> pieces to bpf lib, so we can remove bpf_sys.h altogether?
>>
>> OK, I'll send a new patch replacing bpf_sys.h entirely.
>=20
> Sounds great, thanks!
>=20

Do you prefer a big patch or one for each replaced function?


--bQawRxMqnpDhQ2D5UBPBao38K7DgTCgrV--

--Otd08lEItf39hhpdDRwfhScQEKaFjurWd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliY6uoACgkQIt7+33O9
apVGIQf+PQi9gZUGXTqbZo8PO4uD/6agWUeiGfCwFk56+DGE06vNWvvU1vgZcGBT
zvCt1rslw3EF4SSCbWwloUSKolLtIxB0DO/PiCLLPWa/+TdFHH+Twd+Fal1WNfC1
u+U5uGY8y+uB8eUzqdDOx5H+HtBBoyKF2vXjGWPtdomSN5FXc0njzbxiH0QR7SiW
yJeTum7JqkEb1VY6SrrvkNlauXmqQFfPaeLlkjaaf4gyYdo9nnD9Wt8pfz9HxM5C
ddnkSbvDoq+DR+DErMK2HumQ2QjYETHKhtR6FVdB6mV/DPXv8LuDxzDrYRtweCwM
3HH3L498FZinyA4L0G973v8gdnyTmw==
=987W
-----END PGP SIGNATURE-----

--Otd08lEItf39hhpdDRwfhScQEKaFjurWd--
