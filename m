From: Julian Anastasov <ja@ssi.bg>
Subject: [2.6 PATCH] sctp - provide valid tos and oif values for ip_route_output_key
Date: Wed, 3 Dec 2003 01:49:12 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312030140300.1237-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-506488201-1070408952=:1237"
Cc: Sridhar Samudrala <sri@us.ibm.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-506488201-1070408952=:1237
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	I'm not sure if this change is needed (it is not tested).
Is SO_BINDTODEVICE supported for SCTP? It seems it is bad for
PMTUD not to provide valid tos and oif values for the routing call.

Regards

--
Julian Anastasov <ja@ssi.bg>

--1607745702-506488201-1070408952=:1237
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="tos-sctp-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0312030149120.1237@u.domain.uli>
Content-Description: SCTP tos and oif
Content-Disposition: attachment; filename="tos-sctp-1.diff"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTM1NCAgLT4gMS4xMzU1IA0KIwkg
bmV0L3NjdHAvcHJvdG9jb2wuYwkxLjU4ICAgIC0+IDEuNTkgICANCiMNCiMg
VGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5nZVNldCBMb2cN
CiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0NCiMgMDMvMTIvMDMJamFAc3NpLmJnCTEuMTM1NQ0KIyBbU0NUUF06IHBy
b3ZpZGUgdmFsaWQgdG9zIGFuZCBvaWYgdmFsdWVzIGZvciBpcF9yb3V0ZV9v
dXRwdXRfa2V5DQojIC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tDQojDQpkaWZmIC1OcnUgYS9uZXQvc2N0cC9wcm90b2Nv
bC5jIGIvbmV0L3NjdHAvcHJvdG9jb2wuYw0KLS0tIGEvbmV0L3NjdHAvcHJv
dG9jb2wuYwlXZWQgRGVjICAzIDAxOjA4OjMxIDIwMDMNCisrKyBiL25ldC9z
Y3RwL3Byb3RvY29sLmMJV2VkIERlYyAgMyAwMTowODozMSAyMDAzDQpAQCAt
NDQ0LDYgKzQ0NCw4IEBADQogDQogCW1lbXNldCgmZmwsIDB4MCwgc2l6ZW9m
KHN0cnVjdCBmbG93aSkpOw0KIAlmbC5mbDRfZHN0ICA9IGRhZGRyLT52NC5z
aW5fYWRkci5zX2FkZHI7DQorCWZsLmZsNF90b3MgID0gUlRfQ09OTl9GTEFH
Uyhhc29jLT5iYXNlLnNrKTsNCisJZmwub2lmICAgICAgPSBhc29jLT5iYXNl
LnNrLT5za19ib3VuZF9kZXZfaWY7DQogCWZsLnByb3RvID0gSVBQUk9UT19T
Q1RQOw0KIA0KIAlpZiAoc2FkZHIpDQo=
--1607745702-506488201-1070408952=:1237--
