From: Laurens <masterpe@xs4all.nl>
Subject: New found issues with forcedeth
Date: Thu, 06 Nov 2003 17:55:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068137741.3611.9.camel@lawbox.int.mpe.xs4all.nl>
References: <1068059045.3618.3.camel@lawbox.int.mpe.xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1068059045.3618.3.camel@lawbox.int.mpe.xs4all.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Further testing revealed several other problems, let me first start with
my specs:

Kernel: Linux 2.6.0-test9-mm2 
Distro: Gentoo Base System version 1.4.3.11
CPU: AMD Athlon(tm) XP 2700+
Disk: Maxtor 6Y120P0
Ethernet: nVidia Corporation nForce2
XFree86: 4.3.0
Monitor: Iiyama AS4314UT, TFT-Master Pro 17
Videocard: nVidia Corporation NV15DDR [GeForce2 Ti]
Audio: Creative Labs SB Live! EMU10k1

Issues: 
- dhcpcd eth0 takes longer to load
- emerge sync (gentoo update tool) hangs in the middle of updating
(confirmed not to happen with nvnet)
- modprobe segfaulted on "modprobe -r forcedeth" (note: eth0 was not
active)

On the good side:
- nvnet seems to mess up my framebuffer, forcedeth does not :)

Should you require more information just ask.

good luck,

Lawrence
