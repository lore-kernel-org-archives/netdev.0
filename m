From: Dmitry Kravkov <dmitry@broadcom.com>
Subject: RE: [PATCH net] bnx2x: fix DMA unmapping of TSO split BDs
Date: Thu, 9 Jan 2014 19:23:26 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20E4C2B4@SJEXCHMB06.corp.ad.broadcom.com>
References: <1389274587-6097-1-git-send-email-mschmidt@redhat.com>
 <1389289923.31367.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ariel Elior <ariele@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:15491 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878AbaAITX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 14:23:27 -0500
In-Reply-To: <1389289923.31367.39.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBUaHVyc2RheSwgSmFudWFyeSAwOSwg
MjAxNCA3OjUyIFBNDQo+IFRvOiBNaWNoYWwgU2NobWlkdA0KPiBDYzogbmV0ZGV2QHZnZXIua2Vy
bmVsLm9yZzsgQXJpZWwgRWxpb3I7IFl1dmFsIE1pbnR6OyBEbWl0cnkgS3JhdmtvdjsgRGF2aWQN
Cj4gTWlsbGVyDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0XSBibngyeDogZml4IERNQSB1bm1h
cHBpbmcgb2YgVFNPIHNwbGl0IEJEcw0KPiANCj4gT24gVGh1LCAyMDE0LTAxLTA5IGF0IDE0OjM2
ICswMTAwLCBNaWNoYWwgU2NobWlkdCB3cm90ZToNCj4gPiBibngyeCB0cmlnZ2VycyB3YXJuaW5n
cyB3aXRoIENPTkZJR19ETUFfQVBJX0RFQlVHPXk6DQo+ID4NCj4gPiAgIFdBUk5JTkc6IENQVTog
MCBQSUQ6IDIyNTMgYXQgbGliL2RtYS1kZWJ1Zy5jOjg4Nw0KPiBjaGVja191bm1hcCsweGY4LzB4
OTIwKCkNCj4gPiAgIGJueDJ4IDAwMDA6Mjg6MDAuMDogRE1BLUFQSTogZGV2aWNlIGRyaXZlciBm
cmVlcyBETUEgbWVtb3J5IHdpdGgNCj4gPiAgIGRpZmZlcmVudCBzaXplIFtkZXZpY2UgYWRkcmVz
cz0weDAwMDAwMDAwZGEyYjM4OWVdIFttYXAgc2l6ZT0xNDkwDQo+IGJ5dGVzXQ0KPiA+ICAgW3Vu
bWFwIHNpemU9NjYgYnl0ZXNdDQo+ID4NCj4gPiBUaGUgcmVhc29uIGlzIHRoYXQgYm54Mnggc3Bs
aXRzIGEgVFNPIEJEIGludG8gdHdvIEJEcyAoaGVhZGVycyArIGRhdGEpDQo+ID4gdXNpbmcgb25l
IERNQSBtYXBwaW5nIGZvciBib3RoLCBidXQgaXQgdXNlcyBvbmx5IHRoZSBsZW5ndGggb2YgdGhl
DQo+ID4gZmlyc3QgQkQgd2hlbiB1bm1hcHBpbmcuDQo+ID4NCj4gPiBUaGlzIHBhdGNoIGZpeGVz
IHRoZSBidWcgYnkgdW5tYXBwaW5nIHRoZSB3aG9sZSBsZW5ndGggb2YgdGhlIHR3byBCRHMuDQo+
ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBNaWNoYWwgU2NobWlkdCA8bXNjaG1pZHRAcmVkaGF0LmNv
bT4NCj4gPiAtLS0NCj4gDQo+IFJldmlld2VkLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdv
b2dsZS5jb20+DQo+IA0KDQpUaGFua3MgeW91LCBHdXlzLg0KDQpBY2tlZC1ieTogRG1pdHJ5IEty
YXZrb3YgPGRtaXRyeUBicm9hZGNvbS5jb20+DQoNCg==
