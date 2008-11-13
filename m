From: Volker Armin Hemmann <volker.armin.hemmann@tu-clausthal.de>
Subject: build error with 2.6.27.6+reiser4+ehci-hub patch. ERROR: "mii_ethtool_gset" [drivers/net/r8169.ko] undefined!
Date: Fri, 14 Nov 2008 00:45:19 +0100
Message-ID: <200811140045.20166.volker.armin.hemmann@tu-clausthal.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <greg@kroah.com>, stable@kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755882AbYKMXpo@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
with my old config from 2.6.27.5 (which has the same patches) I get thi=
s=20
error:
make all modules_install install
<snip>
  OBJCOPY arch/x86/boot/setup.bin
  OBJCOPY arch/x86/boot/vmlinux.bin
  HOSTCC  arch/x86/boot/tools/build
  BUILD   arch/x86/boot/bzImage
Root device is (9, 1)
Setup is 11436 bytes (padded to 11776 bytes).
System is 2180 kB
CRC 54816509
Kernel: arch/x86/boot/bzImage is ready  (#1)
  Building modules, stage 2.
  MODPOST 136 modules
ERROR: "mii_ethtool_gset" [drivers/net/r8169.ko] undefined!
make[1]: *** [__modpost] Fehler 1
make: *** [modules] Fehler 2

Gl=FCck Auf,
Volker
