From: linux@horizon.com
Subject: "uli526x: I/O base is zero"
Date: 4 Nov 2006 13:26:40 -0500
Message-ID: <20061104182640.11073.qmail@science.horizon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:11572 "HELO
	science.horizon.com") by vger.kernel.org with SMTP id S965587AbWKDS0l
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Nov 2006 13:26:41 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've got a rather awkward debugging situation.

I helped a friend in another city set up a dual-boot Linux/Windows box
a while ago, and it just got a motherboard upgrade.  Unfortunately, I
had followed my usual instincts and built a custom kernel which didn't
include the new motherboard's drivers.  If I can just get the network
working, I can log in remotely and get everything else going, but until
then, I have to instruct someone in kernel debugging over the telephone.

The motherboard is an MSI K9NU Neo-V ULi M1697 AM2 motherboard,
and PCI device 0000:00:12.0 is an M5263 Ethernet controller,
10b9:5263(rev 60).

It's an older but not ancient 2.6 kernel.  2.6.14, I think, although I
can't seem to find where I wrote it down.  The previous system, which
I set up and was running fine, was a single-core K8, socket 939, with
an nForce4 chipset.  The new one is dual-core and ULi M1697.  So there
are a lot of similarities.

Anyway, we got SMP enabled, and the uli526x driver enabled.  But the
network still didn't work.

Booting with uli526x.debug=1 produced 

uli526x: uli526x_init_one() 0
ACPI: PCI interrupt 0000:00:12.0[A]->GFI 20(level,low)->IRQ 50
uli526x: I/O base is zero

Where I'm confused is the "I/O base is zero" message.  Obviously,
this is a fatal error to the device initialization, but I'm not sure
what causes it.  The obvious "type the error message into google" only
produces a couple of disk images in Romania.

The next step is probably to make and use a more recent boot CD.
But just in case, can I ask:

Can any psychic wizard here suggest, from this very fragmentaty
information, some simple thing I have overlooked that would cause this
problem?

Thank you!
