From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [patch][bonding] fix arp targets' addresses initialization
Date: Tue, 8 Jul 2003 16:40:33 +0300 (IDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0307081249220.8183-300000@jrslxjul1.npdj.intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A01C6B415@hasmsx403.iil.intel.com>
Reply-To: Shmulik Hen <shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="202029822-1412134829-1057671633=:8183"
Cc: linux-netdev <netdev@oss.sgi.com>, Amir Noam <amir.noam@intel.com>,
   bond-devel <bonding-devel@lists.sourceforge.net>,
   Jay Vosburgh <fubar@us.ibm.com>, Noam Marom <noam.marom@intel.com>,
   Shmulik Hen <shmulik.hen@intel.com>,
   "Chad N. Tindel" <ctindel@calma.pair.com>,
   Tsippy Mendelson <tsippy.mendelson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A01C6B415@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--202029822-1412134829-1057671633=:8183
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

	The recent patch to bonding that made it use the standard
in_aton() function introduced a bug. The converted IP addresses are saved
in the wrong array, thus no ARPs are sent at all to any of the addresses
specified.

Attached patches are against latest net-drivers 2.4 and 2.5 trees.


-- 
| Shmulik Hen                             |
| Israel Design Center (Jerusalem)        |
| LAN Access Division                     |
| Intel Communications Group, Intel corp. |


--202029822-1412134829-1057671633=:8183
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="patch-2.4.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0307081640330.8183@jrslxjul1.npdj.intel.com>
Content-Description: patch-2.4.diff
Content-Disposition: attachment; filename="patch-2.4.diff"

ZGlmZiAtTnVhcnAgbmV0LWRyaXZlcnMtMi40L2RyaXZlcnMvbmV0L2JvbmRp
bmcvYm9uZF9tYWluLmMgbmV0LWRyaXZlcnMtMi40LWRldmVsL2RyaXZlcnMv
bmV0L2JvbmRpbmcvYm9uZF9tYWluLmMNCi0tLSBuZXQtZHJpdmVycy0yLjQv
ZHJpdmVycy9uZXQvYm9uZGluZy9ib25kX21haW4uYwlUdWUgSnVsICA4IDE2
OjI1OjM2IDIwMDMNCisrKyBuZXQtZHJpdmVycy0yLjQtZGV2ZWwvZHJpdmVy
cy9uZXQvYm9uZGluZy9ib25kX21haW4uYwlUdWUgSnVsICA4IDE2OjI1OjM3
IDIwMDMNCkBAIC00NjAsNyArNDYwLDcgQEAgc3RydWN0IGJvbmRfcGFybV90
Ymwgew0KIA0KIHN0YXRpYyBpbnQgYXJwX2ludGVydmFsID0gQk9ORF9MSU5L
X0FSUF9JTlRFUlY7DQogc3RhdGljIGNoYXIgKmFycF9pcF90YXJnZXRbTUFY
X0FSUF9JUF9UQVJHRVRTXSA9IHsgTlVMTCwgfTsNCi1zdGF0aWMgdW5zaWdu
ZWQgbG9uZyBhcnBfdGFyZ2V0W01BWF9BUlBfSVBfVEFSR0VUU10gPSB7IDAs
IH0gOw0KK3N0YXRpYyB1MzIgYXJwX3RhcmdldFtNQVhfQVJQX0lQX1RBUkdF
VFNdID0geyAwLCB9IDsNCiBzdGF0aWMgaW50IGFycF9pcF9jb3VudCA9IDA7
DQogc3RhdGljIHUzMiBteV9pcCA9IDA7DQogY2hhciAqYXJwX3RhcmdldF9o
d19hZGRyID0gTlVMTDsNCkBAIC0zOTMwLDcgKzM5MzAsNyBAQCBzdGF0aWMg
aW50IF9faW5pdCBib25kaW5nX2luaXQodm9pZCkNCiAgICAgICAgICAgICAg
ICAgICAgICAgICBhcnBfaW50ZXJ2YWwgPSAwOw0KIAkJfSBlbHNlIHsgDQog
CQkJdTMyIGlwID0gaW5fYXRvbihhcnBfaXBfdGFyZ2V0W2FycF9pcF9jb3Vu
dF0pOyANCi0JCQkqKHUzMiAqKShhcnBfaXBfdGFyZ2V0W2FycF9pcF9jb3Vu
dF0pID0gaXA7DQorCQkJYXJwX3RhcmdldFthcnBfaXBfY291bnRdID0gaXA7
DQogCQl9DQogICAgICAgICB9DQogDQo=
--202029822-1412134829-1057671633=:8183
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="patch-2.5.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.33.0307081640331.8183@jrslxjul1.npdj.intel.com>
Content-Description: patch-2.5.diff
Content-Disposition: attachment; filename="patch-2.5.diff"

ZGlmZiAtTnVhcnAgbmV0LWRyaXZlcnMtMi41L2RyaXZlcnMvbmV0L2JvbmRp
bmcvYm9uZF9tYWluLmMgbmV0LWRyaXZlcnMtMi41LWRldmVsL2RyaXZlcnMv
bmV0L2JvbmRpbmcvYm9uZF9tYWluLmMNCi0tLSBuZXQtZHJpdmVycy0yLjUv
ZHJpdmVycy9uZXQvYm9uZGluZy9ib25kX21haW4uYwlUdWUgSnVsICA4IDE2
OjI1OjUwIDIwMDMNCisrKyBuZXQtZHJpdmVycy0yLjUtZGV2ZWwvZHJpdmVy
cy9uZXQvYm9uZGluZy9ib25kX21haW4uYwlUdWUgSnVsICA4IDE2OjI1OjUw
IDIwMDMNCkBAIC00NDMsNyArNDQzLDcgQEAgc3RydWN0IGJvbmRfcGFybV90
Ymwgew0KIA0KIHN0YXRpYyBpbnQgYXJwX2ludGVydmFsID0gQk9ORF9MSU5L
X0FSUF9JTlRFUlY7DQogc3RhdGljIGNoYXIgKmFycF9pcF90YXJnZXRbTUFY
X0FSUF9JUF9UQVJHRVRTXSA9IHsgTlVMTCwgfTsNCi1zdGF0aWMgdW5zaWdu
ZWQgbG9uZyBhcnBfdGFyZ2V0W01BWF9BUlBfSVBfVEFSR0VUU10gPSB7IDAs
IH0gOw0KK3N0YXRpYyB1MzIgYXJwX3RhcmdldFtNQVhfQVJQX0lQX1RBUkdF
VFNdID0geyAwLCB9IDsNCiBzdGF0aWMgaW50IGFycF9pcF9jb3VudCA9IDA7
DQogc3RhdGljIHUzMiBteV9pcCA9IDA7DQogY2hhciAqYXJwX3RhcmdldF9o
d19hZGRyID0gTlVMTDsNCkBAIC0zODExLDcgKzM4MTEsNyBAQCBzdGF0aWMg
aW50IF9faW5pdCBib25kaW5nX2luaXQodm9pZCkNCiAgICAgICAgICAgICAg
ICAgICAgICAgICBhcnBfaW50ZXJ2YWwgPSAwOw0KIAkJfSBlbHNlIHsgDQog
CQkJdTMyIGlwID0gaW5fYXRvbihhcnBfaXBfdGFyZ2V0W2FycF9pcF9jb3Vu
dF0pOyANCi0JCQkqKHUzMiAqKShhcnBfaXBfdGFyZ2V0W2FycF9pcF9jb3Vu
dF0pID0gaXA7DQorCQkJYXJwX3RhcmdldFthcnBfaXBfY291bnRdID0gaXA7
DQogCQl9DQogICAgICAgICB9DQogDQo=
--202029822-1412134829-1057671633=:8183--
