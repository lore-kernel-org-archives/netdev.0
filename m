From: Wensong Zhang <wensong@linux-vs.org>
Subject: [PATCH] [IPVS] update mark->cw in the WRR scheduler while service
 is updated
Date: Tue, 15 Feb 2005 16:03:10 +0800 (CST)
Message-ID: <Pine.LNX.4.61.0502151559090.5935@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="-1463811584-572891765-1097000265=:2451"
Cc: Julian Anastasov <ja@ssi.bg>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-ID: <Pine.LNX.4.44.0410060217580.2451@penguin.linux-vs.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811584-572891765-1097000265=:2451
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.44.0410060217581.2451@penguin.linux-vs.org>



Hi Dave,

This is the patch for the WRR scheduler in IPVS of kernel 2.4. It's a fix 
for better performance when server weight is adjusted. Please check and 
apply it to kernel 2.4.

Thanks,

Wensong
---1463811584-572891765-1097000265=:2451
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.4-ipvs-wrr.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0502151603100.5935@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="linux-2.4-ipvs-wrr.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5
bGUgcGF0Y2guDQojDQojIENoYW5nZVNldA0KIyAgIDIwMDUvMDIvMTUgMTU6
NTc6MTYrMDg6MDAgd2Vuc29uZ0BsaW51eC12cy5vcmcgDQojICAgW0lQVlNd
IHVwZGF0ZSBtYXJrLT5jdyBpbiB0aGUgV1JSIHNjaGVkdWxlciB3aGlsZSBz
ZXJ2aWNlIGlzIHVwZGF0ZWQNCiMgICANCiMgICBJdCdzIGZvciBiZXR0ZXIg
cGVyZm9ybWFuY2UgaW4gdGhlIFdSUiBzY2hlZHVsaW5nIHdoZW4gc2VydmVy
IHdlaWdodCBpcyBhZGp1c3RlZC4NCiMgICBUaGUgY2hhbmdlIGlzIHBvcnRl
ZCBmcm9tIHRoZSBjaGFuZ2VzIG9mIElQVlMgaW4ga2VybmVsIDIuNi4gVGhh
bmtzIG11c3QgZ28gdG8NCiMgICBLZWVzIEhvZWt6ZW1hIDxrZWVzQHR3ZWFr
ZXJzLm5ldD4gZm9yIGZpbmRpbmcgdGhlIFdSUiBwcm9ibGVtIGluIGtlcm5l
bCAyLjYuDQojICAgDQojIA0KIyBuZXQvaXB2NC9pcHZzL2lwX3ZzX3dyci5j
DQojICAgMjAwNS8wMi8xNSAxNTo1NzoxMSswODowMCB3ZW5zb25nQGxpbnV4
LXZzLm9yZyArMiAtMA0KIyAgIHJlc2V0IG1hcmstPmN3IGlmIG1hcmstPmN3
IGlzIGdyZWF0ZXIgdGhhbiB0aGUgbWF4aW11bSB3ZWlnaHQgd2hpbGUgdXBk
YXRpbmcgc2VydmljZQ0KIyANCmRpZmYgLU5ydSBhL25ldC9pcHY0L2lwdnMv
aXBfdnNfd3JyLmMgYi9uZXQvaXB2NC9pcHZzL2lwX3ZzX3dyci5jDQotLS0g
YS9uZXQvaXB2NC9pcHZzL2lwX3ZzX3dyci5jCTIwMDUtMDItMTUgMTU6NTg6
MTcgKzA4OjAwDQorKysgYi9uZXQvaXB2NC9pcHZzL2lwX3ZzX3dyci5jCTIw
MDUtMDItMTUgMTU6NTg6MTcgKzA4OjAwDQpAQCAtMTQwLDYgKzE0MCw4IEBA
DQogCW1hcmstPmNsID0gJnN2Yy0+ZGVzdGluYXRpb25zOw0KIAltYXJrLT5t
dyA9IGlwX3ZzX3dycl9tYXhfd2VpZ2h0KHN2Yyk7DQogCW1hcmstPmRpID0g
aXBfdnNfd3JyX2djZF93ZWlnaHQoc3ZjKTsNCisJaWYgKG1hcmstPmN3ID4g
bWFyay0+bXcpDQorCQltYXJrLT5jdyA9IDA7DQogCXJldHVybiAwOw0KIH0N
CiANCg==

---1463811584-572891765-1097000265=:2451--
