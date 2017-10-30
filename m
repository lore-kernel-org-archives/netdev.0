From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [patch net-next RFC 1/9] net_sch: red: Add offload ability to RED
 qdisc
Date: Mon, 30 Oct 2017 14:10:16 +0000
Message-ID: <DB5PR05MB1895F4C605BD38C7735BBADEAC590@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <20171030085613.8697-1-jiri@resnulli.us>
        <20171030085613.8697-2-jiri@resnulli.us> <85wp3col9z.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        mlxsw <mlxsw@mellanox.com>, "andrew@lunn.ch" <andrew@lunn.ch>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        "Leon Romanovsky" <leonro@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>,
        "simon.horman@netronome.com" <simon.horman@netronome.com>,
        "pieter.jansen
To: Roman Mashak <mrv@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0061.outbound.protection.outlook.com ([104.47.2.61]:29280
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751959AbdJ3OKU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 10:10:20 -0400
In-Reply-To: <85wp3col9z.fsf@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogUm9tYW4gTWFzaGFrIFtt
YWlsdG86bXJ2QG1vamF0YXR1LmNvbV0NCj4gU2VudDogTW9uZGF5LCBPY3RvYmVyIDMwLCAyMDE3
IDI6NDcgUE0NCj4gVG86IEppcmkgUGlya28gPGppcmlAcmVzbnVsbGkudXM+DQo+IENjOiBuZXRk
ZXZAdmdlci5rZXJuZWwub3JnOyBkYXZlbUBkYXZlbWxvZnQubmV0OyBOb2dhaCBGcmFua2VsIDxu
b2dhaGZAbWVsbGFub3guY29tPjsNCj4gamhzQG1vamF0YXR1LmNvbTsgeGl5b3Uud2FuZ2NvbmdA
Z21haWwuY29tOyBtbHhzdyA8bWx4c3dAbWVsbGFub3guY29tPjsNCj4gYW5kcmV3QGx1bm4uY2g7
IHZpdmllbi5kaWRlbG90QHNhdm9pcmZhaXJlbGludXguY29tOyBmLmZhaW5lbGxpQGdtYWlsLmNv
bTsNCj4gbWljaGFlbC5jaGFuQGJyb2FkY29tLmNvbTsgZ2FuZXNoZ3JAY2hlbHNpby5jb207IFNh
ZWVkIE1haGFtZWVkDQo+IDxzYWVlZG1AbWVsbGFub3guY29tPjsgTWF0YW4gQmFyYWsgPG1hdGFu
YkBtZWxsYW5veC5jb20+OyBMZW9uIFJvbWFub3Zza3kNCj4gPGxlb25yb0BtZWxsYW5veC5jb20+
OyBJZG8gU2NoaW1tZWwgPGlkb3NjaEBtZWxsYW5veC5jb20+Ow0KPiBqYWt1Yi5raWNpbnNraUBu
ZXRyb25vbWUuY29tOyBzaW1vbi5ob3JtYW5AbmV0cm9ub21lLmNvbTsNCj4gcGlldGVyLmphbnNl
bnZhbnZ1dXJlbkBuZXRyb25vbWUuY29tOyBqb2huLmh1cmxleUBuZXRyb25vbWUuY29tOw0KPiBh
bGV4YW5kZXIuaC5kdXlja0BpbnRlbC5jb207IE9yIEdlcmxpdHogPG9nZXJsaXR6QG1lbGxhbm94
LmNvbT47DQo+IGpvaG4uZmFzdGFiZW5kQGdtYWlsLmNvbQ0KPiBTdWJqZWN0OiBSZTogW3BhdGNo
IG5ldC1uZXh0IFJGQyAxLzldIG5ldF9zY2g6IHJlZDogQWRkIG9mZmxvYWQgYWJpbGl0eSB0byBS
RUQgcWRpc2MNCj4gDQo+IEppcmkgUGlya28gPGppcmlAcmVzbnVsbGkudXM+IHdyaXRlczoNCj4g
DQo+IA0KPiBbLi4uXQ0KPiANCj4gPiArc3RhdGljIHZvaWQgcmVkX3Vub2ZmbG9hZChzdHJ1Y3Qg
UWRpc2MgKnNjaCkNCj4gPiArew0KPiA+ICsJc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IHFkaXNj
X2RldihzY2gpOw0KPiA+ICsJc3RydWN0IHRjX3JlZF9xb3B0X29mZmxvYWQgb3B0ID0gew0KPiA+
ICsJCS5oYW5kbGUgPSBzY2gtPmhhbmRsZSwNCj4gPiArCQkuY29tbWFuZCA9IFRDX1JFRF9ERVNU
Uk9ZLA0KPiA+ICsJCS5wYXJlbnQgPSBzY2gtPnBhcmVudCwNCj4gPiArCX07DQo+ID4gKw0KPiA+
ICsJaWYgKCF0Y19jYW5fb2ZmbG9hZChkZXYpIHx8ICFkZXYtPm5ldGRldl9vcHMtPm5kb19zZXR1
cF90YykNCj4gPiArCQlyZXR1cm47DQo+ID4gKw0KPiA+ICsJZGV2LT5uZXRkZXZfb3BzLT5uZG9f
c2V0dXBfdGMoZGV2LCBUQ19TRVRVUF9RRElTQ19SRUQsICAmb3B0KTsNCj4gPiArfQ0KPiA+ICsN
Cj4gDQo+ID4gQEAgLTE2Miw2ICsxNzksMjggQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBubGFfcG9s
aWN5IHJlZF9wb2xpY3lbVENBX1JFRF9NQVggKyAxXSA9IHsNCj4gPiAgCVtUQ0FfUkVEX01BWF9Q
XSA9IHsgLnR5cGUgPSBOTEFfVTMyIH0sDQo+ID4gIH07DQo+ID4NCj4gPiArc3RhdGljIGludCBy
ZWRfb2ZmbG9hZChzdHJ1Y3QgUWRpc2MgKnNjaCkNCj4gPiArew0KPiA+ICsJc3RydWN0IHJlZF9z
Y2hlZF9kYXRhICpxID0gcWRpc2NfcHJpdihzY2gpOw0KPiA+ICsJc3RydWN0IG5ldF9kZXZpY2Ug
KmRldiA9IHFkaXNjX2RldihzY2gpOw0KPiA+ICsJc3RydWN0IHRjX3JlZF9xb3B0X29mZmxvYWQg
b3B0ID0gew0KPiA+ICsJCS5oYW5kbGUgPSBzY2gtPmhhbmRsZSwNCj4gPiArCQkuY29tbWFuZCA9
IFRDX1JFRF9SRVBMQUNFLA0KPiA+ICsJCS5wYXJlbnQgPSBzY2gtPnBhcmVudCwNCj4gPiArCQku
c2V0ID0gew0KPiA+ICsJCQkubWluID0gcS0+cGFybXMucXRoX21pbiA+PiBxLT5wYXJtcy5XbG9n
LA0KPiA+ICsJCQkubWF4ID0gcS0+cGFybXMucXRoX21heCA+PiBxLT5wYXJtcy5XbG9nLA0KPiA+
ICsJCQkucHJvYmFiaWxpdHkgPSBxLT5wYXJtcy5tYXhfUCwNCj4gPiArCQkJLmlzX2VjbiA9IHJl
ZF91c2VfZWNuKHEpLA0KPiA+ICsJCX0sDQo+ID4gKwl9Ow0KPiA+ICsNCj4gPiArCWlmICghdGNf
Y2FuX29mZmxvYWQoZGV2KSB8fCAhZGV2LT5uZXRkZXZfb3BzLT5uZG9fc2V0dXBfdGMpDQo+ID4g
KwkJcmV0dXJuIC1FT1BOT1RTVVBQOw0KPiA+ICsNCj4gPiArCXJldHVybiBkZXYtPm5ldGRldl9v
cHMtPm5kb19zZXR1cF90YyhkZXYsIFRDX1NFVFVQX1FESVNDX1JFRCwgJm9wdCk7DQo+ID4gK30N
Cj4gPiArDQo+IA0KPiBbLi4uXQ0KPiANCj4gQ2FuJ3QgcmVkX3Vub2ZmbG9hZCgpIGFuZCByZWRf
b2ZmbG9hZCgpIGJlIHVuaWZpZWQgaW4gYSBzaW5nbGUgQVBJPyBGb3INCj4gZXhhbXBsZSwgcmVk
X29mZmxvYWQoc3RydWN0IFFkaXNjICpzY2gsIGJvb2wgZW5hYmxlKSA/DQoNCkkgd2lsbCB1bmlm
eSB0aGVtLg0KVGhhbmtzLg0KDQo=
