From: "Ren, Cloud" <cjren@qca.qualcomm.com>
Subject: RE: [PATCH] net: add new QCA alx ethernet driver
Date: Thu, 9 Aug 2012 04:44:08 +0000
Message-ID: <6349D7A510622448B1BA0967850A843801369364@NASANEXD02D.na.qualcomm.com>
References: <1344507270-2907-1-git-send-email-cjren@qca.qualcomm.com>
	 <6349D7A510622448B1BA0967850A8438013692CA@NASANEXD02D.na.qualcomm.com>
 <1344485382.2024.9.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Huang, Xiong" <xiong@qca.qualcomm.com>,
	"Hao-Ran Liu(Joseph Liu)" <hao-ran.liu@canonical.com>,
	"Rodriguez, Luis" <rodrigue@qca.qualcomm.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344485382.2024.9.camel@joe2Laptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgSmVvDQpJIG9ubHkgd2FudCB0byBkbyBzb21lIGFkZGl0aW9uYWwgZXhwbGFuYXRpb25zIHRv
IGRhdmlkLiBJdCBtYWtlcyBub3RoaW5nIHdpdGggb3JpZ2luYWwgcGF0Y2guDQpUaGFua3MNCmNs
b3VkDQoNCi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBKb2UgUGVyY2hlcyBbbWFp
bHRvOmpvZUBwZXJjaGVzLmNvbV0gDQpTZW50OiAyMDEy5bm0OOaciDnml6UgMTI6MTANClRvOiBS
ZW4sIENsb3VkDQpDYzogZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsgbmV0ZGV2QHZnZXIua2VybmVsLm9y
ZzsgbGludXgta2VybmVsQHZnZXIua2VybmVsLm9yZzsgcWNhLWxpbnV4LXRlYW07IG5pYy1kZXZl
bDsgSHVhbmcsIFhpb25nOyBIYW8tUmFuIExpdShKb3NlcGggTGl1KTsgUm9kcmlndWV6LCBMdWlz
DQpTdWJqZWN0OiBSRTogW1BBVENIXSBuZXQ6IGFkZCBuZXcgUUNBIGFseCBldGhlcm5ldCBkcml2
ZXINCg0KT24gVGh1LCAyMDEyLTA4LTA5IGF0IDAyOjI3ICswMDAwLCBSZW4sIENsb3VkIHdyb3Rl
Og0KPiBIaSBEYXZpZCwNCltdDQo+IFRoZSBhbHggZHJpdmVyIG9ubHkgc3VwcG9ydHMgdHdvIG5l
dyBuaWNzKGwxZi9sMmYpIG5vdy4gIEl0IGRvZXNuJ3Qgc3VwZXJzZWRlIGF0bDFjIGRyaXZlci4N
Cj4gQXRsMWMgZHJpdmVyIHN0aWxsIHN1cHBvcnRzIG9sZCBuaWNzLg0KW10NCj4gLS0tLS1Pcmln
aW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogUmVuLCBDbG91ZA0KPiBTZW50OiAyMDEy5bm0OOac
iDnml6UgMTg6MTUNCltdDQo+IFRoaXMgZHJpdmVyIHN1cHBvcnQgdHdvIG5ldyBldGhlcm5ldCBj
aGlwc2V0czoNCg0KWys0MDBrYiBvZiBlbnRpcmUgb3JpZ2luYWwgcGF0Y2hdDQoNCkRpZCB5b3Ug
cmVhbGx5IGhhdmUgdG8gcXVvdGUgNDAwa2Igb2Ygb3JpZ2luYWwgcGF0Y2ggdG8gbWFrZSB0aGF0
IHByZWZpeGluZyBzdGF0ZW1lbnQgdG8gRGF2aWQ/DQoNCltdDQoNCg0KPiBTaWduZWQtb2ZmLWJ5
OiBKb2UgUGVyY2hlcyA8am9lQHBlcmNoZXMuY29tPg0KIA0KSSB3b3VsZCBwcmVmZXIgbXkgbmFt
ZSBub3QgYmUgbGlzdGVkIGFzIGEgU2lnbmVkLW9mZi1ieS4NCg0KSSBkb24ndCBoYXZlIGEgY2Fy
ZCwgSSBuZXZlciB0ZXN0ZWQgaXQsIGV0Yy4gIFdoYXQgSSBkaWQgZG8gaXMgYSBsaWdodCByZXZp
ZXcgYW5kIG1hZGUgYSBjb3VwbGUgb2YgdHJpdmlhbCBwYXRjaCBzdWdnZXN0aW9ucyBhYm91dCBo
b3cgeW91IG1pZ2h0IG1ha2UgbG9nZ2luZyBjb2RlIGEgYml0IHNtYWxsZXIuDQoNClRoYW5rcyBh
bmQgY2hlZXJzLCBKb2UNCg0K
