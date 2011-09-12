From: Bucur Madalin-Cristian-B32716 <B32716@freescale.com>
Subject: RE: [RFC/PATCH] net: add deferred flow cache flush function to be
 used in xfrm
Date: Mon, 12 Sep 2011 14:37:36 +0000
Message-ID: <C857018E177D5F468E08AA85BEA49FA71644B2@039-SN1MPN1-003.039d.mgd.msft.net>
References: <1315829846-15016-1-git-send-email-madalin.bucur@freescale.com>
 <1315835887.2318.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"timo.teras@iki.fi" <timo.teras@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:11739
	"EHLO AM1EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757558Ab1ILOhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2011 10:37:47 -0400
In-Reply-To: <1315835887.2318.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10gT24NCj4gQmVo
YWxmIE9mIEVyaWMgRHVtYXpldA0KPiBTZW50OiBNb25kYXksIFNlcHRlbWJlciAxMiwgMjAxMSA0
OjU4IFBNDQo+IA0KPiBMZSBsdW5kaSAxMiBzZXB0ZW1icmUgMjAxMSDDoCAxNToxNyArMDMwMCwg
TWFkYWxpbiBCdWN1ciBhIMOpY3JpdCA6DQo+ID4gVGhlIHhmcm0gZ2FyYmFnZSBjb2xsZWN0b3Ig
Y2FsbHMgZmxvd19jYWNoZV9mbHVzaCgpIHRoYXQgbWlnaHQgc2xlZXAuDQo+ID4gVGhlIHhmcm0g
Z2FyYmFnZSBjb2xsZWN0b3IgY2FuIGJlIGNhbGxlZCBmcm9tIHNvZnRpcnEgY29udGV4dCwgc3Vj
aCBhcyBmcm9tDQo+ID4gbmV0X3J4X2FjdGlvbigpIHRocm91Z2ggaXBfZm9yd2FyZCgpLiBBZGRl
ZCBmbG93X2NhY2hlX2ZsdXNoX2RlZmVycmVkKCkNCj4gPiBmdW5jdGlvbiB0aGF0IHVzZXMgdGhl
IGtlcm5lbC1nbG9iYWwgd29yayBxdWV1ZSB0byBsZWF2ZSB0aGUgYWN0dWFsDQo+ID4gY2FjaGUg
Zmx1c2ggcHJvY2Vzc2luZyBvdXRzaWRlIHRoZSBzb2Z0aXJxIGNvbnRleHQuDQo+ID4NCj4gDQo+
IFByb2JsZW0gaXMgc29tZXRpbWUgd2UgZG9udCB3YW50IHRvIGRlZmVyIGFuZCBhcmUgaW4gcHJv
Y2VzcyBjb250ZXh0Lg0KPiANCj4geGZybV9kZXZfZXZlbnQoICBldmVudCA9PSBORVRERVZfRE9X
TikgaXMgcHJvYmFibHkgYSBwbGFjZSB3ZSBkb250IHdhbnQNCj4gdG8gZGVmZXIgdGhlIGdhcmJh
Z2UgY29sbGVjdGlvbi4NCj4gDQoNCkluZGVlZCwgY3VycmVudGx5IF9feGZybV9nYXJiYWdlX2Nv
bGxlY3QoKSBpcyBjYWxsZWQgdGhyb3VnaCB0aGUgZ2FyYmFnZV9jb2xsZWN0DQpjYWxsYmFjayBi
dXQgYWxzbyB3aGVuIGFuIGV2ZW50IE5FVERFVl9ET1dOIGlzIHJlY2VpdmVkLiBNYXliZSB3ZSBz
aG91bGQgaGF2ZQ0KZGlmZmVyZW50IGZ1bmN0aW9ucyBmb3IgdGhlIHR3byBjYXNlcywgb25lIGNh
bGxpbmcgZmxvd19jYWNoZV9mbHVzaF9kZWZlcnJlZCgpDQphbmQgdGhlIG90aGVyIGZsb3dfY2Fj
aGVfZmx1c2goKS4NCg0K
