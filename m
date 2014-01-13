From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Mon, 13 Jan 2014 14:18:24 +1100
Message-ID: <20140113141824.4301cb76e8e5540d42d74015@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__13_Jan_2014_14_18_24_+1100_YKCljIiZFd4XvnrD"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__13_Jan_2014_14_18_24_+1100_YKCljIiZFd4XvnrD
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got conflicts in
arch/arc/include/asm/Kbuild, arch/cris/include/asm/Kbuild,
arch/hexagon/include/asm/Kbuild, arch/microblaze/include/asm/Kbuild,
arch/parisc/include/asm/Kbuild and arch/score/include/asm/Kbuild between
commit e3fec2f74f7f ("lib: Add missing arch generic-y entries for
asm-generic/hash.h") from the net-next tree and commit 93ea02bb8435
("arch: Clean up asm/barrier.h implementations using
asm-generic/barrier.h") from the tip tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

BTW: thanks for not keeping the Kbuild files sorted :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc arch/arc/include/asm/Kbuild
index 93e6ca919620,e07c786011af..000000000000
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@@ -1,4 -1,4 +1,5 @@@
  generic-y +=3D auxvec.h
++generic-y +=3D barrier.h
  generic-y +=3D bugs.h
  generic-y +=3D bitsperlong.h
  generic-y +=3D clkdev.h
@@@ -11,6 -11,6 +12,7 @@@ generic-y +=3D fcntl.
  generic-y +=3D fb.h
  generic-y +=3D ftrace.h
  generic-y +=3D hardirq.h
++generic-y +=3D hash.h
  generic-y +=3D hw_irq.h
  generic-y +=3D ioctl.h
  generic-y +=3D ioctls.h
@@@ -47,4 -47,4 +49,3 @@@ generic-y +=3D user.
  generic-y +=3D vga.h
  generic-y +=3D xor.h
  generic-y +=3D preempt.h
- generic-y +=3D hash.h
 -generic-y +=3D barrier.h
diff --cc arch/cris/include/asm/Kbuild
index c5963b3e4624,35ec2e5ca832..000000000000
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@@ -3,8 -3,8 +3,10 @@@ header-y +=3D arch-v10
  header-y +=3D arch-v32/
 =20
 =20
++generic-y +=3D barrier.h
  generic-y +=3D clkdev.h
  generic-y +=3D exec.h
++generic-y +=3D hash.h
  generic-y +=3D kvm_para.h
  generic-y +=3D linkage.h
  generic-y +=3D module.h
@@@ -12,4 -12,4 +14,3 @@@ generic-y +=3D trace_clock.
  generic-y +=3D vga.h
  generic-y +=3D xor.h
  generic-y +=3D preempt.h
- generic-y +=3D hash.h
 -generic-y +=3D barrier.h
diff --cc arch/hexagon/include/asm/Kbuild
index 469d223950ff,a614ec9747a6..000000000000
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@@ -2,6 -2,6 +2,7 @@@
  header-y +=3D ucontext.h
 =20
  generic-y +=3D auxvec.h
++generic-y +=3D barrier.h
  generic-y +=3D bug.h
  generic-y +=3D bugs.h
  generic-y +=3D clkdev.h
@@@ -15,6 -15,6 +16,7 @@@ generic-y +=3D fb.
  generic-y +=3D fcntl.h
  generic-y +=3D ftrace.h
  generic-y +=3D hardirq.h
++generic-y +=3D hash.h
  generic-y +=3D hw_irq.h
  generic-y +=3D ioctl.h
  generic-y +=3D ioctls.h
@@@ -54,4 -54,4 +56,3 @@@ generic-y +=3D ucontext.
  generic-y +=3D unaligned.h
  generic-y +=3D xor.h
  generic-y +=3D preempt.h
- generic-y +=3D hash.h
 -generic-y +=3D barrier.h
diff --cc arch/microblaze/include/asm/Kbuild
index 43eec338ff50,f77fb6630b11..000000000000
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@@ -1,7 -1,7 +1,8 @@@
 =20
++generic-y +=3D barrier.h
  generic-y +=3D clkdev.h
  generic-y +=3D exec.h
++generic-y +=3D hash.h
  generic-y +=3D trace_clock.h
  generic-y +=3D syscalls.h
  generic-y +=3D preempt.h
- generic-y +=3D hash.h
 -generic-y +=3D barrier.h
diff --cc arch/parisc/include/asm/Kbuild
index 75edd5fcc6ff,8df06d0074f4..000000000000
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@@ -1,8 -1,8 +1,9 @@@
 =20
++generic-y +=3D barrier.h
  generic-y +=3D word-at-a-time.h auxvec.h user.h cputime.h emergency-resta=
rt.h \
  	  segment.h topology.h vga.h device.h percpu.h hw_irq.h mutex.h \
  	  div64.h irq_regs.h kdebug.h kvm_para.h local64.h local.h param.h \
  	  poll.h xor.h clkdev.h exec.h
++generic-y +=3D hash.h
  generic-y +=3D trace_clock.h
  generic-y +=3D preempt.h
- generic-y +=3D hash.h
 -generic-y +=3D barrier.h
diff --cc arch/score/include/asm/Kbuild
index 099e7ba40599,ee2993b6e5d1..000000000000
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@@ -1,9 -1,8 +1,9 @@@
 =20
  header-y +=3D
 =20
++generic-y +=3D barrier.h
  generic-y +=3D clkdev.h
++generic-y +=3D hash.h
  generic-y +=3D trace_clock.h
  generic-y +=3D xor.h
  generic-y +=3D preempt.h
- generic-y +=3D hash.h
-=20
 -generic-y +=3D barrier.h

--Signature=_Mon__13_Jan_2014_14_18_24_+1100_YKCljIiZFd4XvnrD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS01sEAAoJEMDTa8Ir7ZwV6zcQAJKcYEZCmdkhK7hXWa8Ea/GI
62mzyUs/jWArJhEWvkjgxJmLevFHzHH0ehxQJaifi9IZRcTaIe35+ZHhsX5ARFqL
/lMEWAPU978p08edz7TglzhDXqOLE3u4MxfsVGoi1DSoJw8ZQlnIIUgRr1X2SDvX
Pvf96k1QzytxV4dkCp/to/PeYckWwhdF2cKuRr40oVJuIhytn/juf0SsWR45jo1S
/zrouvJZQ/7Ckr72CD4MngG/fQsIVknS3IInzmI0HBGwPUNcd19PW74v6JWT6Yqu
CZFUqoCZrmoJHXpaOBreooqKWCvfPQh4+MlAjyPhnRNGnP/a25KXKlPMDS2D8obK
cDy3xhLQsxSisvf3JKO6kc+qF1MkPEKhat4tt+mrbsLX+KWfgL8ZhXNWSjN4Hd8O
5auW1Fqi0r/76zrtwK4JWH1GLuPUezbneQg5GyJXQqeB8tcvd5uiaxMbqJc9FTqk
MtLGljZeQrylSf32l/UZ7oovsZJ/fUB6NR3lek22LIYlY9XxxLkE1AglnLRHw2T1
MR9HJsjSeKd6dRhvmAIKI6UmdUynYRVOb15SSTwA+Z7Ors3pMLrzcGc28bzFDJat
euYp/+6jJJ2fcFxDq/Mmy/MTXw8iKxPxdtEh7D38hCwehVwcCSkHa5bVo+hTL6LU
GD2z2JdqCUr+ukxYa1Zc
=rdHc
-----END PGP SIGNATURE-----

--Signature=_Mon__13_Jan_2014_14_18_24_+1100_YKCljIiZFd4XvnrD--
