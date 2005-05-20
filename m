From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: [PATCH] dummy: improve performance
Date: Fri, 20 May 2005 13:11:24 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505201306110.29305@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1646943047-1317725015-1116583867=:29305"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.62.0505201311150.29305@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1646943047-1317725015-1116583867=:29305
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; format=flowed
Content-ID: <Pine.LNX.4.62.0505201311151.29305@webhosting.rdsbv.ro>

Hello!

Attached patch tries to improve performance of dummy device by activating 
NETIF_F_SG, NETIF_F_NO_CSUM, NETIF_F_HIGHDMA, NETIF_F_FRAGLIST,
NETIF_F_TSO and NETIF_F_LLTX.

Patch compiles and runs.

I tested the speed and seems very low (both old version and the new one).
Something like 37Mbits/s. It is normal?
I can easily get 80Mbit/s on the same machine on ethernet.

Thank you!

Signed-off-by: Catalin BOIE <catab at umbrella.ro>
---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
---1646943047-1317725015-1116583867=:29305
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME=dummy_features.patch
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.62.0505201311070.29305@webhosting.rdsbv.ro>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME=dummy_features.patch

LS0tIGR1bW15MS9kcml2ZXJzL25ldC9kdW1teS5jCTIwMDUtMDMtMjYgMDU6
Mjg6MjAuMDAwMDAwMDAwICswMjAwDQorKysgbGludXgvZHJpdmVycy9uZXQv
ZHVtbXkuYwkyMDA1LTA1LTIwIDExOjU3OjQ0LjAwMDAwMDAwMCArMDMwMA0K
QEAgLTI2LDYgKzI2LDggQEANCiAJCQlOaWNrIEhvbGxvd2F5LCAyN3RoIE1h
eSAxOTk0DQogCVtJIHR3ZWFrZWQgdGhpcyBleHBsYW5hdGlvbiBhIGxpdHRs
ZSBidXQgdGhhdCdzIGFsbF0NCiAJCQlBbGFuIENveCwgMzB0aCBNYXkgMTk5
NA0KKw0KKwlBZGQgc3BlY2lhbCBmZWF0dXJlcyB0byBpbXByb3ZlIHBlcmZv
cm1hbmNlIC0gQ2F0YWxpbiBCT0lFDQogKi8NCiANCiAjaW5jbHVkZSA8bGlu
dXgvY29uZmlnLmg+DQpAQCAtNzMsNiArNzUsOCBAQCBzdGF0aWMgdm9pZCBf
X2luaXQgZHVtbXlfc2V0dXAoc3RydWN0IG5lDQogCWRldi0+ZmxhZ3MgJj0g
fklGRl9NVUxUSUNBU1Q7DQogCVNFVF9NT0RVTEVfT1dORVIoZGV2KTsNCiAJ
cmFuZG9tX2V0aGVyX2FkZHIoZGV2LT5kZXZfYWRkcik7DQorCWRldi0+ZmVh
dHVyZXMgPSBORVRJRl9GX1NHIHwgTkVUSUZfRl9OT19DU1VNIHwgTkVUSUZf
Rl9ISUdIRE1BDQorCQkJfCBORVRJRl9GX0ZSQUdMSVNUIHwgTkVUSUZfRl9U
U08gfCBORVRJRl9GX0xMVFg7DQogfQ0KIA0KIHN0YXRpYyBpbnQgZHVtbXlf
eG1pdChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBzdHJ1Y3QgbmV0X2RldmljZSAq
ZGV2KQ0K

---1646943047-1317725015-1116583867=:29305--
