From: Julian Anastasov <ja@ssi.bg>
Subject: [2.6 PATCH] ipvs - make sure the timer expires on one cpu
Date: Tue, 11 Nov 2003 09:29:19 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311110920420.1155-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-419511311-1068535759=:1155"
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-419511311-1068535759=:1155
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	The attached patch fixes the timer expiration for IPVS.
The goal is to avoid scheduling of running timer on another CPU
in short time (jiffie), ip_vs_conn_expire must run only on one
CPU at time per conn.

Regards

--
Julian Anastasov <ja@ssi.bg>

--1607745702-419511311-1068535759=:1155
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="timer-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0311110929190.1155@u.domain.uli>
Content-Description: ipvs timer fix
Content-Disposition: attachment; filename="timer-1.diff"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTM0OCAgLT4gMS4xMzQ5IA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX2Nvbm4uYwkxLjExICAgIC0+IDEuMTIgICAN
CiMNCiMgVGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5nZVNl
dCBMb2cNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0NCiMgMDMvMTEvMTEJamFAc3NpLmJnCTEuMTM0OQ0KIyBbSVBW
U106IG1ha2Ugc3VyZSB0aGUgdGltZXIgZXhwaXJlcyBvbiBvbmUgY3B1DQoj
IC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
DQojDQpkaWZmIC1OcnUgYS9uZXQvaXB2NC9pcHZzL2lwX3ZzX2Nvbm4uYyBi
L25ldC9pcHY0L2lwdnMvaXBfdnNfY29ubi5jDQotLS0gYS9uZXQvaXB2NC9p
cHZzL2lwX3ZzX2Nvbm4uYwlUdWUgTm92IDExIDA4OjUyOjE2IDIwMDMNCisr
KyBiL25ldC9pcHY0L2lwdnMvaXBfdnNfY29ubi5jCVR1ZSBOb3YgMTEgMDg6
NTI6MTYgMjAwMw0KQEAgLTUzNSw4ICs1MzUsMTAgQEANCiANCiB2b2lkIGlw
X3ZzX2Nvbm5fZXhwaXJlX25vdyhzdHJ1Y3QgaXBfdnNfY29ubiAqY3ApDQog
ew0KLQljcC0+dGltZW91dCA9IDA7DQotCW1vZF90aW1lcigmY3AtPnRpbWVy
LCBqaWZmaWVzKTsNCisJaWYgKGRlbF90aW1lcigmY3AtPnRpbWVyKSkgew0K
KwkJY3AtPnRpbWVvdXQgPSAwOw0KKwkJbW9kX3RpbWVyKCZjcC0+dGltZXIs
IGppZmZpZXMpOw0KKwl9DQogCV9faXBfdnNfY29ubl9wdXQoY3ApOw0KIH0N
CiANCg==
--1607745702-419511311-1068535759=:1155--
