From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 13/17 linux-2.6.7-rc2] prism54: Align skb patch
Date: Sun, 30 May 2004 22:03:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040530215235.0c1f3180@pop.t-online.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=====================_50513794==_"
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=====================_50513794==_
Content-Type: text/plain; charset="us-ascii"; format=flowed

2004-04-26      Margit Schubert-While <margitsw@t-online.de>

* islpci_eth.c, islpci_dev.c : Align skb->data unconditonally after
   allocation. This would appear to improve RX rate.
--=====================_50513794==_
Content-Type: application/octet-stream; name="13-align-skb.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="13-align-skb.patch"

ZGlmZiAtTmF1ckViQiBsaW51eC0yLjYuNmN0L2RyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNtNTQv
aXNscGNpX2Rldi5jIGxpbnV4LTIuNi42LTAxL2RyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNtNTQv
aXNscGNpX2Rldi5jCi0tLSBsaW51eC0yLjYuNmN0L2RyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNt
NTQvaXNscGNpX2Rldi5jCTIwMDQtMDUtMjggMTU6MTQ6NDkuNDIxOTE4NDE2ICswMjAwCisrKyBs
aW51eC0yLjYuNi0wMS9kcml2ZXJzL25ldC93aXJlbGVzcy9wcmlzbTU0L2lzbHBjaV9kZXYuYwky
MDA0LTA1LTI4IDE1OjQzOjE5LjE2Mzk5ODExMiArMDIwMApAQCAtNTYwLDYgKzU2MCw3IEBACiAJ
CQlza2IgPSBOVUxMOwogCQkJZ290byBvdXRfZnJlZTsKIAkJfQorCQlza2JfcmVzZXJ2ZShza2Is
ICg0IC0gKGxvbmcpIHNrYi0+ZGF0YSkgJiAweDAzKTsKIAkJLyogYWRkIHRoZSBuZXcgYWxsb2Nh
dGVkIHNrX2J1ZmYgdG8gdGhlIGJ1ZmZlciBhcnJheSAqLwogCQlwcml2LT5kYXRhX2xvd19yeFtj
b3VudGVyXSA9IHNrYjsKIApkaWZmIC1OYXVyRWJCIGxpbnV4LTIuNi42Y3QvZHJpdmVycy9uZXQv
d2lyZWxlc3MvcHJpc201NC9pc2xwY2lfZXRoLmMgbGludXgtMi42LjYtMDEvZHJpdmVycy9uZXQv
d2lyZWxlc3MvcHJpc201NC9pc2xwY2lfZXRoLmMKLS0tIGxpbnV4LTIuNi42Y3QvZHJpdmVycy9u
ZXQvd2lyZWxlc3MvcHJpc201NC9pc2xwY2lfZXRoLmMJMjAwNC0wNS0yOCAxNTo0NDo0MC44NTE1
Nzk3MTIgKzAyMDAKKysrIGxpbnV4LTIuNi42LTAxL2RyaXZlcnMvbmV0L3dpcmVsZXNzL3ByaXNt
NTQvaXNscGNpX2V0aC5jCTIwMDQtMDUtMjggMTU6NDM6MTkuMTY1OTk3ODA4ICswMjAwCkBAIC00
NDAsNiArNDQwLDcgQEAKIAkJCURFQlVHKFNIT1dfRVJST1JfTUVTU0FHRVMsICJFcnJvciBhbGxv
Y2F0aW5nIHNrYiBcbiIpOwogCQkJYnJlYWs7CiAJCX0KKwkJc2tiX3Jlc2VydmUoc2tiLCAoNCAt
IChsb25nKSBza2ItPmRhdGEpICYgMHgwMyk7CiAJCS8qIHN0b3JlIHRoZSBuZXcgc2tiIHN0cnVj
dHVyZSBwb2ludGVyICovCiAJCWluZGV4ID0gaW5kZXggJSBJU0wzOFhYX0NCX1JYX1FTSVpFOwog
CQlwcml2LT5kYXRhX2xvd19yeFtpbmRleF0gPSBza2I7Cg==
--=====================_50513794==_--
