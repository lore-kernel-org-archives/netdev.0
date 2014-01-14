From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the tip tree with the net-next tree
Date: Tue, 14 Jan 2014 16:44:20 +1100
Message-ID: <20140114164420.d296fbcc4be3a5f126c86069@canb.auug.org.au>
References: <20140113142059.f9f1c58c391b2c8bbd05699f@canb.auug.org.au>
	<20140114140214.7279bcaf88d7a4514d889186@canb.auug.org.au>
	<52D4C25F.8060804@zytor.com>
	<20140113.211946.205101073261467184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__14_Jan_2014_16_44_20_+1100_ZUiNbAZys/.R+jFz"
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@kernel.org,
	peterz@infradead.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140113.211946.205101073261467184.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__14_Jan_2014_16_44_20_+1100_ZUiNbAZys/.R+jFz
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__14_Jan_2014_16_44_20_+1100_7BleTZ=yvYU=Yypq"


--Multipart=_Tue__14_Jan_2014_16_44_20_+1100_7BleTZ=yvYU=Yypq
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 13 Jan 2014 21:19:46 -0800 (PST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: "H. Peter Anvin" <hpa@zytor.com>
> Date: Mon, 13 Jan 2014 20:51:43 -0800
>=20
> > Is there a sensible way we can fix this in either net-next or tip?
>=20
> I think if I sort the files in net-next the problem will go away,
> if someone can confirm this I'll do it.

I have attached 2 patches: one for net-next and one for tip/auto-latest
(but should be applicable in the appropriate topic branch).  If both are
applied to their respect trees, then I get no conflict when merging the
two trees.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Multipart=_Tue__14_Jan_2014_16_44_20_+1100_7BleTZ=yvYU=Yypq
Content-Type: text/x-diff;
 name="0001-net-resort-some-Kbuild-files-to-hopefully-help-avoid.patch"
Content-Disposition: attachment;
 filename="0001-net-resort-some-Kbuild-files-to-hopefully-help-avoid.patch"
Content-Transfer-Encoding: quoted-printable

>From da6b3ed2f43d1a0c5e946d11902c167eb6188cca Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 14 Jan 2014 16:37:45 +1100
Subject: [PATCH] net: resort some Kbuild files to hopefully help avoid some
 conflicts

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 arch/arc/include/asm/Kbuild        | 2 +-
 arch/cris/include/asm/Kbuild       | 2 +-
 arch/hexagon/include/asm/Kbuild    | 2 +-
 arch/microblaze/include/asm/Kbuild | 2 +-
 arch/mn10300/include/asm/Kbuild    | 2 +-
 arch/score/include/asm/Kbuild      | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 93e6ca919620..cf29d84fd9c2 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -11,6 +11,7 @@ generic-y +=3D fcntl.h
 generic-y +=3D fb.h
 generic-y +=3D ftrace.h
 generic-y +=3D hardirq.h
+generic-y +=3D hash.h
 generic-y +=3D hw_irq.h
 generic-y +=3D ioctl.h
 generic-y +=3D ioctls.h
@@ -47,4 +48,3 @@ generic-y +=3D user.h
 generic-y +=3D vga.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D hash.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index c5963b3e4624..406cbd3ebd58 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -5,6 +5,7 @@ header-y +=3D arch-v32/
=20
 generic-y +=3D clkdev.h
 generic-y +=3D exec.h
+generic-y +=3D hash.h
 generic-y +=3D kvm_para.h
 generic-y +=3D linkage.h
 generic-y +=3D module.h
@@ -12,4 +13,3 @@ generic-y +=3D trace_clock.h
 generic-y +=3D vga.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D hash.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbu=
ild
index 469d223950ff..ae45d75a3187 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -15,6 +15,7 @@ generic-y +=3D fb.h
 generic-y +=3D fcntl.h
 generic-y +=3D ftrace.h
 generic-y +=3D hardirq.h
+generic-y +=3D hash.h
 generic-y +=3D hw_irq.h
 generic-y +=3D ioctl.h
 generic-y +=3D ioctls.h
@@ -54,4 +55,3 @@ generic-y +=3D ucontext.h
 generic-y +=3D unaligned.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D hash.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/a=
sm/Kbuild
index 43eec338ff50..ca60945ddf30 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -1,7 +1,7 @@
=20
 generic-y +=3D clkdev.h
 generic-y +=3D exec.h
+generic-y +=3D hash.h
 generic-y +=3D trace_clock.h
 generic-y +=3D syscalls.h
 generic-y +=3D preempt.h
-generic-y +=3D hash.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbu=
ild
index bc42f14c9c2e..199345207d82 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -1,6 +1,6 @@
=20
 generic-y +=3D clkdev.h
 generic-y +=3D exec.h
+generic-y +=3D hash.h
 generic-y +=3D trace_clock.h
 generic-y +=3D preempt.h
-generic-y +=3D hash.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index 099e7ba40599..1d35e33ccf86 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -2,8 +2,8 @@
 header-y +=3D
=20
 generic-y +=3D clkdev.h
+generic-y +=3D hash.h
 generic-y +=3D trace_clock.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D hash.h
=20
--=20
1.8.5.2


--Multipart=_Tue__14_Jan_2014_16_44_20_+1100_7BleTZ=yvYU=Yypq
Content-Type: text/x-diff;
 name="0001-tip-resort-some-Kbuild-files-to-hopefully-help-avoid.patch"
Content-Disposition: attachment;
 filename="0001-tip-resort-some-Kbuild-files-to-hopefully-help-avoid.patch"
Content-Transfer-Encoding: quoted-printable

>From 6d0a3746f35cb879189228093728251b7ce04135 Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 14 Jan 2014 16:36:10 +1100
Subject: [PATCH] tip: resort some Kbuild files to hopefully help avoid some
 conflicts

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 arch/arc/include/asm/Kbuild        | 2 +-
 arch/cris/include/asm/Kbuild       | 2 +-
 arch/hexagon/include/asm/Kbuild    | 2 +-
 arch/microblaze/include/asm/Kbuild | 2 +-
 arch/mn10300/include/asm/Kbuild    | 2 +-
 arch/parisc/include/asm/Kbuild     | 2 +-
 arch/score/include/asm/Kbuild      | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index e07c786011af..9ae21c198007 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -1,4 +1,5 @@
 generic-y +=3D auxvec.h
+generic-y +=3D barrier.h
 generic-y +=3D bugs.h
 generic-y +=3D bitsperlong.h
 generic-y +=3D clkdev.h
@@ -47,4 +48,3 @@ generic-y +=3D user.h
 generic-y +=3D vga.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 35ec2e5ca832..199b1a9dab89 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -3,6 +3,7 @@ header-y +=3D arch-v10/
 header-y +=3D arch-v32/
=20
=20
+generic-y +=3D barrier.h
 generic-y +=3D clkdev.h
 generic-y +=3D exec.h
 generic-y +=3D kvm_para.h
@@ -12,4 +13,3 @@ generic-y +=3D trace_clock.h
 generic-y +=3D vga.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbu=
ild
index a614ec9747a6..ada843c701ef 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -2,6 +2,7 @@
 header-y +=3D ucontext.h
=20
 generic-y +=3D auxvec.h
+generic-y +=3D barrier.h
 generic-y +=3D bug.h
 generic-y +=3D bugs.h
 generic-y +=3D clkdev.h
@@ -54,4 +55,3 @@ generic-y +=3D ucontext.h
 generic-y +=3D unaligned.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/a=
sm/Kbuild
index f77fb6630b11..a82426589fff 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -1,7 +1,7 @@
=20
+generic-y +=3D barrier.h
 generic-y +=3D clkdev.h
 generic-y +=3D exec.h
 generic-y +=3D trace_clock.h
 generic-y +=3D syscalls.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbu=
ild
index 367ef399ddf7..032143ec2324 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -1,6 +1,6 @@
=20
+generic-y +=3D barrier.h
 generic-y +=3D clkdev.h
 generic-y +=3D exec.h
 generic-y +=3D trace_clock.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 8df06d0074f4..34b0be4ca52d 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -1,8 +1,8 @@
=20
+generic-y +=3D barrier.h
 generic-y +=3D word-at-a-time.h auxvec.h user.h cputime.h emergency-restar=
t.h \
 	  segment.h topology.h vga.h device.h percpu.h hw_irq.h mutex.h \
 	  div64.h irq_regs.h kdebug.h kvm_para.h local64.h local.h param.h \
 	  poll.h xor.h clkdev.h exec.h
 generic-y +=3D trace_clock.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index ee2993b6e5d1..fe7471eb0167 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -1,8 +1,8 @@
=20
 header-y +=3D
=20
+generic-y +=3D barrier.h
 generic-y +=3D clkdev.h
 generic-y +=3D trace_clock.h
 generic-y +=3D xor.h
 generic-y +=3D preempt.h
-generic-y +=3D barrier.h
--=20
1.8.5.2


--Multipart=_Tue__14_Jan_2014_16_44_20_+1100_7BleTZ=yvYU=Yypq--

--Signature=_Tue__14_Jan_2014_16_44_20_+1100_ZUiNbAZys/.R+jFz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJS1M64AAoJEMDTa8Ir7ZwVu4MP/iKvN+UL2uacqXmr+hVmrzkr
Poujf0syPdtSYorxWUqWRgf0jThok8q1Gf4SCY7TNL5bSxw4ISeQEQgnPZ0KKQlK
KyOdaShEd6g2gMv8n6M6Y6WHwHTFXcyjbBeAKsFF8kEaN+JnqFLJ8qrKGg5sup3A
QQrNgbQKVz4wk3QHH9gEBwd1YHPCdyLGEeI0eDnmyiFe3pYSEda8eGDVmgL8ncdz
1HypNrMaKmnvpzGFRacW+bqG88B4+ESpRYi3x5j340CcZBjVOu1uf/6hEZmdu1Js
4Z9gSBFOQavwn7A5U3+I0h2XM/4lf5GBuRkaP3BH5R9wu9iNY9NaSKz/STGVCK5n
tPzChzutsFnUNVDrKr/7SEfKWOyd3GPMMgvv8WqXiE2sKaadPLI/QjOSBQodwM40
MfpZ2amokMhB+nfjRQ/cYsAF/i9cblOE3hmUn4on/pZjnuerQSVQwFQpttY30bwj
OviixAHiM0nw9QSixXU+bRhsTwSBIdnIRfjsqODoZLF+88FTX7uxdYT3toKqp8FQ
yXeVBK1cyQ+6lDsvZVlfkLOopp8n6up+QS4LOopG/UydzUCi7uUD5pxNG+eJpDnA
aCYb56siHTCQPzgHn5RnJ8isk8TG5aQGEmk3Ula6WA/CXKwJ+TjrOvFpWbq3QwLs
vPCY10JQ/E2qos6XNPLB
=Y9EF
-----END PGP SIGNATURE-----

--Signature=_Tue__14_Jan_2014_16_44_20_+1100_ZUiNbAZys/.R+jFz--
