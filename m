From: Michal Vanco <vanco@satro.sk>
Subject: e1000 packet corruption problem
Date: Tue, 29 Mar 2005 10:55:49 +0200
Message-ID: <42491815.8020106@satro.sk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig11FCE980CC115488B31E8637"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig11FCE980CC115488B31E8637
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I saw this issue mentioned several times in various lists, but no
satisfactory answer was given.

I have 4-port Intel e1000 card in my dual Amd Opteron machine:
0000:02:04.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
Controller (rev 02)
0000:02:05.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
Controller (rev 02)
0000:02:06.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
Controller (rev 02)
0000:02:07.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
Controller (rev 02)

with this driver:
Intel(R) PRO/1000 Network Driver - version 5.7.6
Copyright (c) 1999-2004 Intel Corporation.
ACPI: PCI interrupt 0000:02:04.0[A] -> GSI 28 (level, low) -> IRQ 201
e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt 0000:02:05.0[A] -> GSI 29 (level, low) -> IRQ 209
e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt 0000:02:06.0[A] -> GSI 30 (level, low) -> IRQ 217
e1000: eth5: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI interrupt 0000:02:07.0[A] -> GSI 31 (level, low) -> IRQ 225
e1000: eth6: e1000_probe: Intel(R) PRO/1000 Network Connection

eth3 is autonegotiated at 100 Mbps FDX.

Trying to forward packets through eth3 causes corruption of packets.
I've got 'Corrupted MAC on input' trying to download (or copy) something
using scp. Using ftp doesn't emit any error, but all files downloaded
are apparently corrupted.

After that I've tried to disable all off-loading. In this case no error
is visible but all download stalls forever.

Is this problem related only to e1000 driver or any GigE cards? Is there
any fix available?

regards,
michal

--------------enig11FCE980CC115488B31E8637
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCSRgYSBxxqpMaGkMRAlB6AKCh/F4vLI44PMlnM2EOZzNmYyBa2QCfdyvl
t4CA7Qmuz019GH9/vI2jbvU=
=44vr
-----END PGP SIGNATURE-----

--------------enig11FCE980CC115488B31E8637--
