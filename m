From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the
 library
Date: Mon, 6 Feb 2017 20:16:09 +0100
Message-ID: <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fN7WiWQ99bonxdSQliH0IEx7JD1N7g8x6"
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Shuah Khan <shuah@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58989691.7060403@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fN7WiWQ99bonxdSQliH0IEx7JD1N7g8x6
Content-Type: multipart/mixed; boundary="n1P4B4WighvD6tSHcavO5XUaxPc0R0Dwj";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>
To: Daniel Borkmann <daniel@iogearbox.net>, linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
 Shuah Khan <shuah@kernel.org>
Message-ID: <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the
 library
References: <20170205231428.23846-1-mic@digikod.net>
 <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net>
In-Reply-To: <58989691.7060403@iogearbox.net>

--n1P4B4WighvD6tSHcavO5XUaxPc0R0Dwj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On 06/02/2017 16:30, Daniel Borkmann wrote:
> On 02/06/2017 12:14 AM, Micka=C3=ABl Sala=C3=BCn wrote:
>> Replace bpf_prog_load() with bpf_load_program() calls.
>>
>> Use the tools include directory instead of the installed one to allow
>> builds from other kernels.
>>
>> Signed-off-by: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>
>> Cc: Alexei Starovoitov <ast@fb.com>
>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Shuah Khan <shuah@kernel.org>
>> ---
>>   tools/testing/selftests/bpf/Makefile        |  6 +++++-
>>   tools/testing/selftests/bpf/bpf_sys.h       | 21 -------------------=
--
>>   tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
>>   tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
>>   4 files changed, 14 insertions(+), 27 deletions(-)
>=20
> No objections, but if so, can't we add the remaining missing
> pieces to bpf lib, so we can remove bpf_sys.h altogether?
>=20
> Thanks,
> Daniel
>=20

OK, I'll send a new patch replacing bpf_sys.h entirely.

 Micka=C3=ABl


--n1P4B4WighvD6tSHcavO5XUaxPc0R0Dwj--

--fN7WiWQ99bonxdSQliH0IEx7JD1N7g8x6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAliYy3kACgkQIt7+33O9
apUx3Qf/RbtD4TSB+o8+C3g68gCTa4sXUvFXK1jFnBGe/LCnHR5Bra2J6SLzSyQA
6fhoG/XTQLGe3o2uDSOZ9BJXNgWp7HXpzvDV7uOMB2PnZzGgz26ot6gFJvaI5ctp
VJ1qmpeHT4RyteYV3/Bc1RhiuAlIKh1fRsB3Xv5hpwfEdJPS+KwLukf1vcHEV+/8
i8AKkpNHb8k4HYdZ4TH+Ci9TM05H1B3K5vzh1a35zNAJiT3neOpgqitc5XF1/nxl
n7Se0TAUFcbmRi1vHcyRbLR1KqnI9ShUpvIajHJgvk10XfWsMlWD5JGH0VSP9j1u
jbLizuexTNsG1IpiXx6MpU5Mf9ELRg==
=rTwi
-----END PGP SIGNATURE-----

--fN7WiWQ99bonxdSQliH0IEx7JD1N7g8x6--
