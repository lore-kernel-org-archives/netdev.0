From: Andreas Schwab <schwab@suse.de>
Subject: Bad UDP checksum with 82540EM
Date: Sat, 07 Feb 2004 14:35:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <je65ejvwpa.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cramerj@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm getting bad UPD checksums in outgoing packets with the e1000 driver
(version 5.2.16) in 2.6.1 when using HW checksumming on a HP branded
82540EM on ia64 (TCP works fine).  The same driver works fine with an
Intel branded chip.  The two devices are identified as follows:

  Model: "Hewlett-Packard Company 82540EM Gigabit Ethernet Controller"
  Vendor: pci 0x8086 "Intel Corporation"
  Device: pci 0x100e "82540EM Gigabit Ethernet Controller"
  SubVendor: pci 0x103c "Hewlett-Packard Company"
  SubDevice: pci 0x1274=20

  Model: "Intel 82540EM Gigabit Ethernet Controller"
  Vendor: pci 0x8086 "Intel Corporation"
  Device: pci 0x100e "82540EM Gigabit Ethernet Controller"
  SubVendor: pci 0x8086 "Intel Corporation"
  SubDevice: pci 0x3402=20

After disabling tx-checksumming UDP is working again.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
