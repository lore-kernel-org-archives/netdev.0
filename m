From: Julian Anastasov <ja@ssi.bg>
Subject: [2.6 PATCH] bridge - provide valid tos value for ip_route_output_key
Date: Wed, 3 Dec 2003 02:03:20 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312030156410.1237-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-1706568113-1070409800=:1237"
Cc: Bart De Schuymer <bdschuym@pandora.be>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-1706568113-1070409800=:1237
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	The attached patch changes bridging to provide valid
tos value to routing.

Regards

--
Julian Anastasov <ja@ssi.bg>

--1607745702-1706568113-1070409800=:1237
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="tos-bridge-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0312030203200.1237@u.domain.uli>
Content-Description: bridge tos
Content-Disposition: attachment; filename="tos-bridge-1.diff"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTM1MSAgLT4gMS4xMzUyIA0KIwlu
ZXQvYnJpZGdlL2JyX25ldGZpbHRlci5jCTEuMTUgICAgLT4gMS4xNiAgIA0K
Iw0KIyBUaGUgZm9sbG93aW5nIGlzIHRoZSBCaXRLZWVwZXIgQ2hhbmdlU2V0
IExvZw0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLQ0KIyAwMy8xMi8wMglqYUBzc2kuYmcJMS4xMzUyDQojIFtCUklE
R0VdOiBwcm92aWRlIHZhbGlkIHRvcyB2YWx1ZSBmb3IgaXBfcm91dGVfb3V0
cHV0X2tleQ0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLQ0KIw0KZGlmZiAtTnJ1IGEvbmV0L2JyaWRnZS9icl9uZXRm
aWx0ZXIuYyBiL25ldC9icmlkZ2UvYnJfbmV0ZmlsdGVyLmMNCi0tLSBhL25l
dC9icmlkZ2UvYnJfbmV0ZmlsdGVyLmMJVHVlIERlYyAgMiAyMzo1NTozMCAy
MDAzDQorKysgYi9uZXQvYnJpZGdlL2JyX25ldGZpbHRlci5jCVR1ZSBEZWMg
IDIgMjM6NTU6MzAgMjAwMw0KQEAgLTE4MCw3ICsxODAsNyBAQA0KIAkJCXN0
cnVjdCBydGFibGUgKnJ0Ow0KIAkJCXN0cnVjdCBmbG93aSBmbCA9IHsgLm5s
X3UgPSANCiAJCQl7IC5pcDRfdSA9IHsgLmRhZGRyID0gaXBoLT5kYWRkciwg
LnNhZGRyID0gMCAsDQotCQkJCSAgICAgLnRvcyA9IGlwaC0+dG9zfSB9LCAu
cHJvdG8gPSAwfTsNCisJCQkJICAgICAudG9zID0gUlRfVE9TKGlwaC0+dG9z
KX0gfSwgLnByb3RvID0gMH07DQogDQogCQkJaWYgKCFpcF9yb3V0ZV9vdXRw
dXRfa2V5KCZydCwgJmZsKSkgew0KIAkJCQkvKiBCcmlkZ2VkLWFuZC1ETkFU
J2VkIHRyYWZmaWMgZG9lc24ndA0K
--1607745702-1706568113-1070409800=:1237--
