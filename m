From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: (2/5) Use free_netdev() as destructor in ip6_tunnel.c
Date: Mon, 1 Sep 2003 02:46:45 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309010244200.26242-200000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0309010235070.26242-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-1258061687-1062373605=:26242"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
In-Reply-To: <Pine.LNX.4.44.0309010235070.26242-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-1258061687-1062373605=:26242
Content-Type: TEXT/PLAIN; charset=US-ASCII

Oops,
forgot to attach the patch in the original mail...

Sorry about that,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-1258061687-1062373605=:26242
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="ip6_tnl_free_netdev.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309010246450.26242@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: attachment; filename="ip6_tnl_free_netdev.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTI3Ni4yOC4xIC0+IDEuMTI3Ni4y
OC4yDQojCW5ldC9pcHY2L2lwNl90dW5uZWwuYwkxLjcgICAgIC0+IDEuOCAg
ICANCiMNCiMgVGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5n
ZVNldCBMb2cNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0NCiMgMDMvMDkvMDEJdm51b3J2YWxAZHNsLWhraWd3MWE4
Yi5kaWFsLmluZXQuZmkJMS4xMjc2LjI4LjINCiMgVXNlIGZyZWVfbmV0ZGV2
IGFzIGlwNl90dW5uZWwgZGV2aWNlIGRlc3RydWN0b3INCiMgLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCiMNCmRpZmYg
LU5ydSBhL25ldC9pcHY2L2lwNl90dW5uZWwuYyBiL25ldC9pcHY2L2lwNl90
dW5uZWwuYw0KLS0tIGEvbmV0L2lwdjYvaXA2X3R1bm5lbC5jCU1vbiBTZXAg
IDEgMDE6NTc6MzcgMjAwMw0KKysrIGIvbmV0L2lwdjYvaXA2X3R1bm5lbC5j
CU1vbiBTZXAgIDEgMDE6NTc6MzcgMjAwMw0KQEAgLTEwODIsNyArMTA4Miw3
IEBADQogew0KIAlTRVRfTU9EVUxFX09XTkVSKGRldik7DQogCWRldi0+dW5p
bml0ID0gaXA2aXA2X3RubF9kZXZfdW5pbml0Ow0KLQlkZXYtPmRlc3RydWN0
b3IgPSAodm9pZCAoKikoc3RydWN0IG5ldF9kZXZpY2UgKikpa2ZyZWU7DQor
CWRldi0+ZGVzdHJ1Y3RvciA9IGZyZWVfbmV0ZGV2Ow0KIAlkZXYtPmhhcmRf
c3RhcnRfeG1pdCA9IGlwNmlwNl90bmxfeG1pdDsNCiAJZGV2LT5nZXRfc3Rh
dHMgPSBpcDZpcDZfdG5sX2dldF9zdGF0czsNCiAJZGV2LT5kb19pb2N0bCA9
IGlwNmlwNl90bmxfaW9jdGw7DQo=
---377318441-1258061687-1062373605=:26242--
