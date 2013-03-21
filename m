From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 20:13:54 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20BEB3E0@SJEXCHMB06.corp.ad.broadcom.com>
References: <1363841553.3333.47.camel@edumazet-glaptop>
 <20130321.114616.279859400813363663.davem@davemloft.net>
 <1363882091.4431.20.camel@edumazet-glaptop>
 <CAM8tLiPh=g1+XqhwKQAH7XyTmpT80j5422VXGjLksxtFxYoxRQ@mail.gmail.com>
 <CANP3RGfKTQtbhecy=gjxqW+jsnoqEofTspJJfdd1_rAk2YNkEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Pravin B Shelar" <pshelar@nicira.com>,
	"Hsiao-keng Jerry Chu" <hkchu@google.com>
To: =?utf-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>,
	"Dmitry Kravkov" <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1777 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab3CUUOY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 16:14:24 -0400
In-Reply-To: <CANP3RGfKTQtbhecy=gjxqW+jsnoqEofTspJJfdd1_rAk2YNkEw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNYWNpZWogxbtlbmN6eWtvd3Nr
aSBbbWFpbHRvOm1hemVAZ29vZ2xlLmNvbV0NCj4gU2VudDogVGh1cnNkYXksIE1hcmNoIDIxLCAy
MDEzIDEwOjA4IFBNDQo+IFRvOiBEbWl0cnkgS3Jhdmtvdg0KPiBDYzogRXJpYyBEdW1hemV0OyBE
YXZpZCBNaWxsZXI7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IERtaXRyeSBLcmF2a292OyBFaWxv
biBHcmVlbnN0ZWluOyBQcmF2aW4gQiBTaGVsYXI7IEhzaWFvLWtlbmcgSmVycnkgQ2h1DQo+IFN1
YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHRdIGdybzogcmVsYXggSUQgY2hlY2sgaW4gaW5ldF9n
cm9fcmVjZWl2ZSgpDQo+IA0KPiA+IFRoaXMgaXMgY29ycmVjdDogSUQgb25seSBmb3Igb25lIG9m
IHRoZSBoZWFkZXJzIGNhbiBiZSBoYW5kbGVkIHdpdGggY3VycmVudCBGVy9IVywgZm9yIG90aGVy
IERGIGlzIHNldC4NCj4gDQo+IEkgd291bGQgcHJlZmVyIGZvciBJUCBJRCB0byBiZSBjb3JyZWN0
bHkgaW5jcmVtZW50ZWQgb24gdGhlIGlubmVyIElQdjQNCj4gcGFja2V0IHJhdGhlciB0aGFuIHRo
ZSBvdXRlciBJUHY0Lg0KPiBDb3VsZCB0aGF0IGJlIGNoYW5nZWQ/DQoNClllcywgSSB3aWxsIGNo
ZWNrIGlmIGl0IGNhbiBiZSBkb25lIGluIGRyaXZlciBvbmx5IC4uLiANCg==
