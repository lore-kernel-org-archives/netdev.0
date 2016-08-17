From: Jonatan Magnusson <jonatan.magnusson@gmail.com>
Subject: Failing to get link up with ENC28J60 + Beaglebone
Date: Wed, 17 Aug 2016 13:56:27 +0200
Message-ID: <D487BC0A-B931-4633-AA2F-09192661A916@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, mhei@heimpold.de, jic23@kernel.org,
	dompe@hpe.com, broonie@kernel.org, afd@ti.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35540 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbcHQL4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 07:56:30 -0400
Received: by mail-qk0-f196.google.com with SMTP id o1so9046421qkd.2
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 04:56:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi

I=E2=80=99m evaluating ENC28J60 for a new design, so I=E2=80=99ve got =
myself a module from ebay and verified that it works perfectly with =
Raspberry Pi.

Now I=E2=80=99m trying to get it to work on a Beaglebone (Beaglebone =
Green Wireless). After some struggles the device tree seems right and =
I=E2=80=99ve checked all signals (CS, MOSI, MISO, CLK, INT) with an =
oscilloscope and it looks perfect. SPI max frequency is set to a low =
value: 100 kHz. The driver is loaded and the device is detected and =
after boot I have an eth0 interface. But I can=E2=80=99t get it to link =
up state.

I=E2=80=99ve now enabled lots of debug messages and first thing I =
noticed is that the hardware revision (EREVID) is consistently reported =
as 0x3C. I=E2=80=99ve not seen any mentions of hardware revisions above =
7 so that looks suspicios. Do you think you could help me there? What is =
the expected EREVID?

I=E2=80=99ve seen other people having trouble with ENC28J60 + Beaglebone =
on the web, but I=E2=80=99m not ready to give up that easily...

Here=E2=80=99s output of enc28j60_dump_regs:

[    9.083081] enc28j60: Enter enc28j60_dump_regs
[    9.143364] enc28j60 Hw initialized.
[    9.143364] HwRevID: 0x3c
[    9.143364] Cntrl: ECON1 ECON2 ESTAT  EIR  EIE
[    9.143364]        0x0f  0xc0  0x03  0x00  0x00
[    9.143364] MAC  : MACON1 MACON3 MACON4
[    9.143364]        0xf3   0x0c   0x00
[    9.143364] Rx   : ERXST  ERXND  ERXWRPT ERXRDPT ERXFCON EPKTCNT =
MAMXFL
[    9.143364]        0x0000 0xc3ff 0x0000  0xc3ff  0x03    0x00    =
0x33fc
[    9.143364] Tx   : ETXST  ETXND  MACLCON1 MACLCON2 MAPHSUP
[    9.143364]        0xcc00 0xffff 0xff     0x3f     0x00


Best regards,
Jonatan Magnusson
