From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: net/usb device additions for -stable
Date: Tue, 13 Nov 2012 21:25:58 +0100
Message-ID: <877gppuu5l.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Jay Purohit <jspurohit@velocitylimitless.com>,
	Valdis Kletnieks <valdis.kletnieks@vt.edu>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	Olof Ermis <olof.ermis@gmail.com>,
	Tommy Cheng <tommy7765@yahoo.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53263 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755796Ab2KMUfo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 15:35:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I looked quickly through the list of added devices in the range
v3.6..net/master and tried to cherry-pick them into the current 3.0,
3.2, 3.4 and 3.6 stable trees.  There weren't really that many. The
result was:

# for stable-3.6:
af1b85e usb/ipheth: Add iPhone 5 support
c6846ee net: qmi_wwan: adding more ZTE devices
bbc8d92 net: cdc_ncm: add Huawei devices

# for stable-3.4:
af1b85e usb/ipheth: Add iPhone 5 support

# for stable-3.2:
af1b85e usb/ipheth: Add iPhone 5 support

# for stable-3.0:
af1b85e usb/ipheth: Add iPhone 5 support



=46or completeness, these three patches were also applied after 3.6 but=
 are
not in the list above for the given reasons:

42d94dc net: qmi_wwan: adding Huawei E367, ZTE MF683 and Pantech P4200
 - does not apply cleanly to any stable relase. I'll send a backport
   if/when I get around to it.

66dc81e asix: Adds support for Lenovo 10/100 USB dongle.
 - already applied to stable-3.6 and does not apply to anything earlier

f8295ec qmi_wwan/cdc_ether: move Novatel 551 and E362 to qmi_wwan
 - already applied to stable-3.6 and does not apply to anything earlier



Bj=C3=B8rn
