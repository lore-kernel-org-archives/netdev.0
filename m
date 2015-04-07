From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 7 Apr 2015 17:00:56 +1000
Message-ID: <20150407170056.2d89261e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/H773TF+Zhn8FqOzXUYuz1Yh"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/H773TF+Zhn8FqOzXUYuz1Yh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in
include/linux/bpf.h between commit 0fc174dea545 ("ebpf: make internal
bpf API independent of CONFIG_BPF_SYSCALL ifdefs") from the net-next
tree and commit 4e537f7fbdce ("bpf: Make internal bpf API independent
of CONFIG_BPF_SYSCALL #ifdefs") from the tip tree.

I fixed it up (they are the same patch and there are other changes in
the net-next tree, so I just used that version) and can carry the fix
as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/H773TF+Zhn8FqOzXUYuz1Yh
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVI4CuAAoJEMDTa8Ir7ZwVKV8P/1GIN4F85xZTG2FO64xc0EOT
f2TbldvAz4DMjY+3xHPbUWFuDU143HI1JzDahYYJYUf7EKS46VynoF5s/9mb1Svg
RTNXHoZOkkVQ9R7USp/IFn5rtnoPN5uTy5HTo8HTUt1trrT02TlRPygaI+izx6Mv
Gq/yRujhqBDnMpWQLdUJ+HIfmllNsHQYCnHrWX14pI7w7xJKJRwVqzojgL4ibbJz
Ge91keuDmtPF6cfWpGKeYBiUUiNpaJEf+iz4kI8G/aOYVvJPRxtety0PX7/vWxst
ba4H3DXTnEfIqn2E92EdpdRPVKlLH5wVQVeSxoTS0cpbhyesGM+YLsUdLGwjNGFu
PiU5ERoaSbLB7JIuPsppMEZfubTyZw6Iawa0AJRHpm4O46ynGzjDJyS+uHxJukhe
NDAuuskfk+IRSJ52BMVYXswhkByHFpjqYBDNvAQRJMy/djCRAKATeExhWiNF9gyQ
e9fRbz9UklC6rhh1GvAHsr54/gRuYf48Chp/vLw5P0vuaZwME/SHK8qU36XxkZuB
kcUvsilWo6OMtbU8TtU3x6RSpib3vWFvJmHKyqe9yQqSbPy0HUlNOxV30HdpNWHt
+9UgdPRBW4vy8SjI10uvmgD9SY6vr0+FXc+cA7M0/VWSMETz3gM6rP38dBD2zf/w
k2M+2PotczjqOSe9o0hV
=HpWn
-----END PGP SIGNATURE-----

--Sig_/H773TF+Zhn8FqOzXUYuz1Yh--
