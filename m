From: Arthur Kepner <akepner@sgi.com>
Subject: [PATCH] tg3 h/w flow control autoneg
Date: Tue, 25 May 2004 12:20:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.SGI.4.56.0405251158550.9934718@neteng.engr.sgi.com>
References: <20040524072657.GC27177@sgi.com> <20040524004045.58b3eb44.davem@redhat.com>
 <20040524080431.GD27177@sgi.com> <20040524100634.1349295d.davem@redhat.com>
 <20040525010434.GA31134@sgi.com> <20040525105101.2da85469.davem@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1072017398-1172901112-1085512805=:9934718"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040525105101.2da85469.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---1072017398-1172901112-1085512805=:9934718
Content-Type: TEXT/PLAIN; charset=US-ASCII


We found that packets were mysteriously being discarded by
our Broadcom 570X hardware under heavy receive load. This
occurred especially when multiple NICs were in use.

The problem turned out to be that h/w flow control wasn't
being used, even after that should have been autonegotiated.
The attached patch (against 2.6.6) fixes that.

--

Arthur
---1072017398-1172901112-1085512805=:9934718
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="autoneg.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.SGI.4.56.0405251220050.9934718@neteng.engr.sgi.com>
Content-Description: tg3 h/w flow control autoneg patch
Content-Disposition: attachment; filename="autoneg.patch"

LS0tIGxpbnV4Lm9yaWcvZHJpdmVycy9uZXQvdGczLmMJMjAwNC0wNS0yNSAx
MToyNjowMy4wMDAwMDAwMDAgLTA3MDANCisrKyBsaW51eC0yLjYuNi9kcml2
ZXJzL25ldC90ZzMuYwkyMDA0LTA1LTI1IDExOjM4OjEzLjAwMDAwMDAwMCAt
MDcwMA0KQEAgLTEwMjcsNiArMTAyNyw4IEBADQogc3RhdGljIHZvaWQgdGcz
X3NldHVwX2Zsb3dfY29udHJvbChzdHJ1Y3QgdGczICp0cCwgdTMyIGxvY2Fs
X2FkdiwgdTMyIHJlbW90ZV9hZHYpDQogew0KIAl1MzIgbmV3X3RnM19mbGFn
cyA9IDA7DQorCXUzMiBvbGRfcnhfbW9kZSA9IHRwLT5yeF9tb2RlOw0KKwl1
MzIgb2xkX3R4X21vZGUgPSB0cC0+dHhfbW9kZTsNCiANCiAJaWYgKGxvY2Fs
X2FkdiAmIEFEVkVSVElTRV9QQVVTRV9DQVApIHsNCiAJCWlmIChsb2NhbF9h
ZHYgJiBBRFZFUlRJU0VfUEFVU0VfQVNZTSkgew0KQEAgLTEwNTcsMTAgKzEw
NTksMTggQEANCiAJZWxzZQ0KIAkJdHAtPnJ4X21vZGUgJj0gflJYX01PREVf
RkxPV19DVFJMX0VOQUJMRTsNCiANCisJaWYgKG9sZF9yeF9tb2RlICE9IHRw
LT5yeF9tb2RlKSB7DQorCQl0dzMyX2YoTUFDX1JYX01PREUsIHRwLT5yeF9t
b2RlKTsNCisJfQ0KKwkNCiAJaWYgKG5ld190ZzNfZmxhZ3MgJiBURzNfRkxB
R19UWF9QQVVTRSkNCiAJCXRwLT50eF9tb2RlIHw9IFRYX01PREVfRkxPV19D
VFJMX0VOQUJMRTsNCiAJZWxzZQ0KIAkJdHAtPnR4X21vZGUgJj0gflRYX01P
REVfRkxPV19DVFJMX0VOQUJMRTsNCisNCisJaWYgKG9sZF90eF9tb2RlICE9
IHRwLT50eF9tb2RlKSB7DQorCQl0dzMyX2YoTUFDX1RYX01PREUsIHRwLT50
eF9tb2RlKTsNCisJfQ0KIH0NCiANCiBzdGF0aWMgdm9pZCB0ZzNfYXV4X3N0
YXRfdG9fc3BlZWRfZHVwbGV4KHN0cnVjdCB0ZzMgKnRwLCB1MzIgdmFsLCB1
MTYgKnNwZWVkLCB1OCAqZHVwbGV4KQ0K

---1072017398-1172901112-1085512805=:9934718--
