From: "Meng, Jilin" <Jilin.Meng@emc.com>
Subject: RE: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Thu, 11 Apr 2013 03:13:42 +0000
Message-ID: <027526AF93736D4380632CD4F3B42B8002FEBD@MX101CL02.corp.emc.com>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
	 <514C6CAA.2090902@cogentembedded.com>
 <1363963666.4431.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hop-nat-141.emc.com ([168.159.213.141]:31198 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759682Ab3DKDOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 23:14:51 -0400
In-Reply-To: <1363963666.4431.61.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhhbmtzIFNlcmdlaSBmb3IgaW50cm9kdWNpbmcgYSBmYXN0IGZ1bmN0aW9uLg0KDQotLS0tLU9y
aWdpbmFsIE1lc3NhZ2UtLS0tLQ0KRnJvbTogbmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZyBb
bWFpbHRvOm5ldGRldi1vd25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBFcmljIER1
bWF6ZXQNClNlbnQ6IEZyaWRheSwgTWFyY2ggMjIsIDIwMTMgMTA6NDggUE0NClRvOiBTZXJnZWkg
U2h0eWx5b3YNCkNjOiBNZW5nLCBKaWxpbjsgZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsga3V6bmV0QG1z
Mi5pbnIuYWMucnU7IGptb3JyaXNAbmFtZWkub3JnOyB5b3NoZnVqaUBsaW51eC1pcHY2Lm9yZzsg
a2FiZXJAdHJhc2gubmV0OyBTdW4sIFlpbmdsaW47IFByaXRodmlyYWosIExha3NobWFuYW47IG5l
dGRldkB2Z2VyLmtlcm5lbC5vcmcNClN1YmplY3Q6IFJlOiBbUEFUQ0hdIG5ldDogRml4IHRlbnRh
dGl2ZSBJUHY2IGFkZHJlc3MgZHVlIHRvIERBRCBsb29waW5nIGJhY2sNCg0KT24gRnJpLCAyMDEz
LTAzLTIyIGF0IDE4OjM3ICswNDAwLCBTZXJnZWkgU2h0eWx5b3Ygd3JvdGU6DQoNCj4gICAgIERv
bid0IHdlIGhhdmUgbWVtY21wKCkgaW4gTGludXg/DQo+IA0KDQpEb250IHVzZSBzbG93IG1lbWNt
cCgpIGluIHRoaXMgY29udGV4dCBidXQgZmFzdA0KZXRoZXJfYWRkcl9lcXVhbF82NGJpdHMoKQ0K
DQoNCg0KLS0NClRvIHVuc3Vic2NyaWJlIGZyb20gdGhpcyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1
bnN1YnNjcmliZSBuZXRkZXYiIGluIHRoZSBib2R5IG9mIGEgbWVzc2FnZSB0byBtYWpvcmRvbW9A
dmdlci5rZXJuZWwub3JnIE1vcmUgbWFqb3Jkb21vIGluZm8gYXQgIGh0dHA6Ly92Z2VyLmtlcm5l
bC5vcmcvbWFqb3Jkb21vLWluZm8uaHRtbA0KDQo=
