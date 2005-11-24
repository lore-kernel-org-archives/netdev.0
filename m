From: Frank Sorenson <frank@tuxrocks.com>
Subject: Re: Mouse issues in -mm
Date: Wed, 23 Nov 2005 23:14:40 -0700
Message-ID: <43855A50.80808@tuxrocks.com>
References: <20051123033550.00d6a6e8.akpm@osdl.org> <20051123113854.07fca702.akpm@osdl.org> <4385202E.70404@tuxrocks.com> <200511232226.44459.dtor_core@ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Marc Koschewski <marc@osknowledge.org>,
	linux-kernel@vger.kernel.org, Harald Welte <laforge@netfilter.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161011AbVKXGO7@vger.kernel.org>
To: Dmitry Torokhov <dtor_core@ameritech.net>
In-Reply-To: <200511232226.44459.dtor_core@ameritech.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Dmitry Torokhov wrote:
> What kind of touchpad do you have? Could you post your
> /pros/bus/input/devices please?

AlpsPS/2 ALPS GlidePoint

/proc/bus/input/devices:
I: Bus=0010 Vendor=001f Product=0001 Version=0100
N: Name="PC Speaker"
P: Phys=isa0061/input0
S: Sysfs=/class/input/input0
H: Handlers=kbd event0
B: EV=40001
B: SND=46

I: Bus=0011 Vendor=0001 Product=0001 Version=ab41
N: Name="AT Translated Set 2 keyboard"
P: Phys=isa0060/serio0/input0
S: Sysfs=/class/input/input1
H: Handlers=kbd event1
B: EV=120013
B: KEY=4 2000000 3802078 f840d001 f2ffffdf ffefffff ffffffff fffffffe
B: MSC=10
B: LED=7

I: Bus=0011 Vendor=0002 Product=0008 Version=0000
N: Name="PS/2 Mouse"
P: Phys=isa0060/serio1/input1
S: Sysfs=/class/input/input2
H: Handlers=mouse0 event2
B: EV=7
B: KEY=70000 0 0 0 0 0 0 0 0
B: REL=3

I: Bus=0011 Vendor=0002 Product=0008 Version=7321
N: Name="AlpsPS/2 ALPS GlidePoint"
P: Phys=isa0060/serio1/input0
S: Sysfs=/class/input/input3
H: Handlers=mouse1 event3
B: EV=f
B: KEY=420 0 70000 0 0 0 0 0 0 0 0
B: REL=3
B: ABS=1000003


Note: I believe this issue may also be related to the mouse protocol
extension.  I typically run with 'psmouse.proto=exps' on the kernel
command line, and the psmouse resync patch seems to break tapping in
that mode.  However, booting without proto=exps seems to continue to
work, even with the resync patch (though the touchpad is unusably
sensitive--hence the use of exps in the first place).

Thanks,

Frank
- --
Frank Sorenson - KD7TZK
Systems Manager, Computer Science Department
Brigham Young University
frank@tuxrocks.com
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFDhVpQaI0dwg4A47wRAgxMAKCgcX59rpVR2umCUz4IBNls8L+8EQCfQprd
4v8Qxv3890dRIus0ptIyGxs=
=AJGF
-----END PGP SIGNATURE-----
