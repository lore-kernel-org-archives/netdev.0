From: Wensong Zhang <wensong@linux-vs.org>
Subject: [PATCH] [IPVS] Fixed that the WRR scheduler works correctly when
 server is updated or overloaded
Date: Tue, 15 Feb 2005 01:00:38 +0800 (CST)
Message-ID: <Pine.LNX.4.61.0502150054180.2895@penguin.linux-vs.org>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="-1463811584-572891765-1097000265=:2451"
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

Here is the patch to make the WRR scheduler work correctly when server is 
updated with new weight or marked overloaded. Please check and apply it to 
kernel 2.6.

Thanks,

Wensong
---1463811584-572891765-1097000265=:2451
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="linux-2.6-ipvs-wrr.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.61.0502150100380.2895@penguin.linux-vs.org>
Content-Description: 
Content-Disposition: attachment; filename="linux-2.6-ipvs-wrr.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5
bGUgcGF0Y2guDQojDQojIENoYW5nZVNldA0KIyAgIDIwMDUvMDIvMTUgMDA6
NDQ6MTcrMDg6MDAgd2Vuc29uZ0BsaW51eC12cy5vcmcgDQojICAgW0lQVlNd
IEZpeGVkIHRoYXQgdGhlIFdSUiBzY2hlZHVsZXIgd29ya3MgY29ycmVjdGx5
IHdoZW4gc2VydmVyIGlzIHVwZGF0ZWQgb3Igb3ZlcmxvYWRlZC4NCiMgICAN
CiMgICBUaGFua3MgbXVzdCBnbyB0byBLZWVzIEhvZWt6ZW1hIDxrZWVzQHR3
ZWFrZXJzLm5ldD4gZm9yIGRpc292ZXJpbmcgdGhlDQojICAgcHJvYmxlbSBh
bmQgcHJvdmlkaW5nIGEgcGF0Y2guIFRoYW5rcyBnbyB0byBKdWxpYW4gYW5k
IEhvcm1zIGZvciBkaXNjdXNzaW9uDQojICAgYW5kIG1ha2luZyB0aGlzIHBh
dGNoLg0KIyANCiMgbmV0L2lwdjQvaXB2cy9pcF92c193cnIuYw0KIyAgIDIw
MDUvMDIvMTUgMDA6NDM6NTArMDg6MDAgd2Vuc29uZ0BsaW51eC12cy5vcmcg
KzMgLTENCiMgICBmaXhlZCB0byByZXNldCBtYXJrLT5jdyBpZiBtYXJrLT5j
dyBpcyBncmVhdGVyIHRoYW4gbWF4aW11bSB3ZWlnaHQgd2hpbGUgdXBkYXRp
bmcgc2VydmljZTsNCiMgICBmaXhlZCB0byByZXR1cm4gTlVMTCBvbmx5IHdo
ZW4gYWxsIHRoZSBzZXJ2ZXJzIGFyZSBub3QgYXZhaWxhYmxlIGF0IGFueSB3
ZWlnaHQuDQojICAgDQojIA0KZGlmZiAtTnJ1IGEvbmV0L2lwdjQvaXB2cy9p
cF92c193cnIuYyBiL25ldC9pcHY0L2lwdnMvaXBfdnNfd3JyLmMNCi0tLSBh
L25ldC9pcHY0L2lwdnMvaXBfdnNfd3JyLmMJMjAwNS0wMi0xNSAwMDo0Njow
NSArMDg6MDANCisrKyBiL25ldC9pcHY0L2lwdnMvaXBfdnNfd3JyLmMJMjAw
NS0wMi0xNSAwMDo0NjowNSArMDg6MDANCkBAIC0xMjYsNiArMTI2LDggQEAN
CiAJbWFyay0+Y2wgPSAmc3ZjLT5kZXN0aW5hdGlvbnM7DQogCW1hcmstPm13
ID0gaXBfdnNfd3JyX21heF93ZWlnaHQoc3ZjKTsNCiAJbWFyay0+ZGkgPSBp
cF92c193cnJfZ2NkX3dlaWdodChzdmMpOw0KKwlpZiAobWFyay0+Y3cgPiBt
YXJrLT5tdykNCisJCW1hcmstPmN3ID0gMDsNCiAJcmV0dXJuIDA7DQogfQ0K
IA0KQEAgLTE4Niw3ICsxODgsNyBAQA0KIAkJCX0NCiAJCX0NCiANCi0JCWlm
IChtYXJrLT5jbCA9PSBwKSB7DQorCQlpZiAobWFyay0+Y2wgPT0gcCAmJiBt
YXJrLT5jdyA9PSBtYXJrLT5kaSkgew0KIAkJCS8qIGJhY2sgdG8gdGhlIHN0
YXJ0LCBhbmQgbm8gZGVzdCBpcyBmb3VuZC4NCiAJCQkgICBJdCBpcyBvbmx5
IHBvc3NpYmxlIHdoZW4gYWxsIGRlc3RzIGFyZSBPVkVSTE9BREVEICovDQog
CQkJZGVzdCA9IE5VTEw7DQo=

---1463811584-572891765-1097000265=:2451--
