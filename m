From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.6 PATCH] ipvs - make sure the timer expires on one cpu
Date: Tue, 11 Nov 2003 10:07:17 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311111004540.1176-200000@u.domain.uli>
References: <Pine.LNX.4.44.0311110920420.1155-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-1832032584-1068538037=:1176"
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0311110920420.1155-200000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-1832032584-1068538037=:1176
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	Ah, sorry. It is bad idea to set cp->timeout to 0. Please,
better use the attached patch instead.

Regards

--
Julian Anastasov <ja@ssi.bg>

--1607745702-1832032584-1068538037=:1176
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="timer-2.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0311111007170.1176@u.domain.uli>
Content-Description: fix ipvs timer, v2
Content-Disposition: attachment; filename="timer-2.diff"

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
cHZzL2lwX3ZzX2Nvbm4uYwlUdWUgTm92IDExIDEwOjA0OjE4IDIwMDMNCisr
KyBiL25ldC9pcHY0L2lwdnMvaXBfdnNfY29ubi5jCVR1ZSBOb3YgMTEgMTA6
MDQ6MTggMjAwMw0KQEAgLTUzNSw4ICs1MzUsOCBAQA0KIA0KIHZvaWQgaXBf
dnNfY29ubl9leHBpcmVfbm93KHN0cnVjdCBpcF92c19jb25uICpjcCkNCiB7
DQotCWNwLT50aW1lb3V0ID0gMDsNCi0JbW9kX3RpbWVyKCZjcC0+dGltZXIs
IGppZmZpZXMpOw0KKwlpZiAoZGVsX3RpbWVyKCZjcC0+dGltZXIpKQ0KKwkJ
bW9kX3RpbWVyKCZjcC0+dGltZXIsIGppZmZpZXMpOw0KIAlfX2lwX3ZzX2Nv
bm5fcHV0KGNwKTsNCiB9DQogDQo=
--1607745702-1832032584-1068538037=:1176--
