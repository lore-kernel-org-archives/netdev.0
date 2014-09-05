From: "Frank.Li@freescale.com" <Frank.Li@freescale.com>
Subject: RE: [PATCH RFC 1/1] net: fec: change data structure to support
 multiqueue
Date: Fri, 5 Sep 2014 20:40:57 +0000
Message-ID: <2a925db95ede48c9924f9416e471cea1@BLUPR03MB486.namprd03.prod.outlook.com>
References: <1409945994-15593-1-git-send-email-Frank.Li@freescale.com>
 <CAOMZO5B08M6n0rXfgZkVNb-0awVQdJ56aMokimCunVsjg03AZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0143.outbound.protection.outlook.com ([157.56.110.143]:3728
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751144AbaIEVO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 17:14:29 -0400
In-Reply-To: <CAOMZO5B08M6n0rXfgZkVNb-0awVQdJ56aMokimCunVsjg03AZg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogRmFiaW8gRXN0ZXZhbSBb
bWFpbHRvOmZlc3RldmFtQGdtYWlsLmNvbV0NCj4gU2VudDogRnJpZGF5LCBTZXB0ZW1iZXIgMDUs
IDIwMTQgMzozMyBQTQ0KPiBUbzogTGkgRnJhbmstQjIwNTk2DQo+IENjOiBGbG9yaWFuIEZhaW5l
bGxpOyBEdWFuIEZ1Z2FuZy1CMzg2MTE7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVj
dDogUmU6IFtQQVRDSCBSRkMgMS8xXSBuZXQ6IGZlYzogY2hhbmdlIGRhdGEgc3RydWN0dXJlIHRv
IHN1cHBvcnQNCj4gbXVsdGlxdWV1ZQ0KPiANCj4gT24gRnJpLCBTZXAgNSwgMjAxNCBhdCA0OjM5
IFBNLCBGcmFuayBMaSA8RnJhbmsuTGlAZnJlZXNjYWxlLmNvbT4gd3JvdGU6DQo+IA0KPiA+ICsg
ICAgICAgdHhxID0ga3phbGxvYyhzaXplb2YoKnR4cSksIEdGUF9LRVJORUwpOw0KPiA+ICsgICAg
ICAgaWYgKCF0eHEpDQo+ID4gKyAgICAgICAgICAgICAgIHJldHVybiAtRU5PTUVNOw0KPiA+ICsg
ICAgICAgZmVwLT50eF9xdWV1ZVswXSA9IHR4cTsNCj4gPiArDQo+ID4gKyAgICAgICByeHEgPSBr
emFsbG9jKHNpemVvZigqcnhxKSwgR0ZQX0tFUk5FTCk7DQo+ID4gKyAgICAgICBpZiAoIXJ4cSkg
ew0KPiA+ICsgICAgICAgICAgICAgICBrZnJlZSh0eHEpOw0KPiA+ICsgICAgICAgICAgICAgICBy
ZXR1cm4gLUVOT01FTTsNCj4gPiArICAgICAgIH0NCj4gDQo+IC4uLi4NCj4gDQo+ID4gICAgICAg
ICAvKiBBbGxvY2F0ZSBtZW1vcnkgZm9yIGJ1ZmZlciBkZXNjcmlwdG9ycy4gKi8NCj4gPiAtICAg
ICAgIGNiZF9iYXNlID0gZG1hX2FsbG9jX2NvaGVyZW50KE5VTEwsIGJkX3NpemUsICZmZXAtPmJk
X2RtYSwNCj4gPiArICAgICAgIGNiZF9iYXNlID0gZG1hX2FsbG9jX2NvaGVyZW50KE5VTEwsIGJk
X3NpemUsICZiZF9kbWEsDQo+ID4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICBHRlBfS0VSTkVMKTsNCj4gPiAgICAgICAgIGlmICghY2JkX2Jhc2UpDQo+ID4gICAgICAgICAg
ICAgICAgIHJldHVybiAtRU5PTUVNOw0KPiANCj4gWW91IHNob3VsZCBrZnJlZSB0eHEgYW5kIHJ4
cSBiZWZvcmUgcmV0dXJuaW5nIGhlcmUuDQoNClllcywgDQpBY3R1YWxseSB0aGlzIHBhcnQgY29k
ZSB3aWxsIGJlIHJld3JpdGUgdG90YWxseSBpbiBuZXh0IHBhdGNoLiANCllvdSBjYW4gcmVmZXIg
b3JpZ2luYWwgcGF0Y2ggc2VyaWFsLiANCg0KQmVzdCByZWdhcmRzDQpGcmFuayBMaQ0K
