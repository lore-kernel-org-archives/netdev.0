From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH net-next 07/27] gianfar: remove use of VLAN_TAG_PRESENT
Date: Tue, 13 Dec 2016 12:09:25 +0000
Message-ID: <AM5PR0401MB2561A8DC4A63BCB292717B69969B0@AM5PR0401MB2561.eurprd04.prod.outlook.com>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
 <244d34e8fb9a120fa79c40f06e9da7e10c1c0536.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0083.outbound.protection.outlook.com ([104.47.2.83]:64934
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932650AbcLMRoH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 12:44:07 -0500
In-Reply-To: <244d34e8fb9a120fa79c40f06e9da7e10c1c0536.1481586602.git.mirq-linux@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogTWljaGHFgiBNaXJvc8WCYXcgW21h
aWx0bzptaXJxLWxpbnV4QHJlcmUucW1xbS5wbF0NCj5TZW50OiBUdWVzZGF5LCBEZWNlbWJlciAx
MywgMjAxNiAyOjEzIEFNDQo+VG86IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj5DYzogQ2xhdWRp
dSBNYW5vaWwgPGNsYXVkaXUubWFub2lsQGZyZWVzY2FsZS5jb20+DQo+U3ViamVjdDogW1BBVENI
IG5ldC1uZXh0IDA3LzI3XSBnaWFuZmFyOiByZW1vdmUgdXNlIG9mIFZMQU5fVEFHX1BSRVNFTlQN
Cj4NCj5TaWduZWQtb2ZmLWJ5OiBNaWNoYcWCIE1pcm9zxYJhdyA8bWlycS1saW51eEByZXJlLnFt
cW0ucGw+DQo+LS0tDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9naWFuZmFyX2V0
aHRvb2wuYyB8IDggKysrLS0tLS0NCj4gMSBmaWxlIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwg
NSBkZWxldGlvbnMoLSkNCj4NCj5kaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvZnJl
ZXNjYWxlL2dpYW5mYXJfZXRodG9vbC5jDQo+Yi9kcml2ZXJzL25ldC9ldGhlcm5ldC9mcmVlc2Nh
bGUvZ2lhbmZhcl9ldGh0b29sLmMNCj5pbmRleCA1NjU4OGYyLi45NWZhNjQ3IDEwMDY0NA0KPi0t
LSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9naWFuZmFyX2V0aHRvb2wuYw0KPisr
KyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9naWFuZmFyX2V0aHRvb2wuYw0KPkBA
IC0xMTU1LDExICsxMTU1LDkgQEAgc3RhdGljIGludCBnZmFyX2NvbnZlcnRfdG9fZmlsZXIoc3Ry
dWN0DQo+ZXRodG9vbF9yeF9mbG93X3NwZWMgKnJ1bGUsDQo+IAkJcHJpbyA9IHZsYW5fdGNpX3By
aW8ocnVsZSk7DQo+IAkJcHJpb19tYXNrID0gdmxhbl90Y2lfcHJpb20ocnVsZSk7DQo+DQo+LQkJ
aWYgKGNmaSA9PSBWTEFOX1RBR19QUkVTRU5UICYmIGNmaV9tYXNrID09DQo+VkxBTl9UQUdfUFJF
U0VOVCkgew0KPi0JCQl2bGFuIHw9IFJRRlBSX0NGSTsNCj4tCQkJdmxhbl9tYXNrIHw9IFJRRlBS
X0NGSTsNCj4tCQl9IGVsc2UgaWYgKGNmaSAhPSBWTEFOX1RBR19QUkVTRU5UICYmDQo+LQkJCSAg
IGNmaV9tYXNrID09IFZMQU5fVEFHX1BSRVNFTlQpIHsNCj4rCQlpZiAoY2ZpX21hc2spIHsNCj4r
CQkJaWYgKGNmaSkNCj4rCQkJCXZsYW4gfD0gUlFGUFJfQ0ZJOw0KPiAJCQl2bGFuX21hc2sgfD0g
UlFGUFJfQ0ZJOw0KPiAJCX0NCj4gCX0NCg0KUmV2aWV3ZWQtYnk6IENsYXVkaXUgTWFub2lsIDxj
bGF1ZGl1Lm1hbm9pbEBueHAuY29tPg0K
