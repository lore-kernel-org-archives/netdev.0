From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Thu, 23 Jun 2016 09:03:12 +0000
Message-ID: <CO2PR11MB0088EB77AF72E6F8AD6781DB972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <576B1AE8.6030309@hpe.com> <576B31C0.8090301@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Rick Jones <rick.jones2@hpe.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0138.outbound.protection.outlook.com ([65.55.169.138]:37198
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750954AbcFWJDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 05:03:16 -0400
In-Reply-To: <576B31C0.8090301@hpe.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IE15IHN5c3RlbXMgYXJlIHByZXNlbnRseSBpbiB0aGUgbWlkc3Qgb2YgYW4gaW5zdGFsbCBi
dXQgSSBzaG91bGQgYmUNCj4gPiBhYmxlIHRvIGRlbW9uc3RyYXRlIGl0IGluIHRoZSBtb3JuaW5n
IChVUyBQYWNpZmljIHRpbWUsIG1vZHVsbyB0aGUNCj4gPiBzaHV0dGxlIHNlcnZpY2Ugb2YgYSBj
YXIgcmVwYWlyIHBsYWNlKQ0KPiANCj4gc3RhY2tAbnAtY3AxLWNvbXAwMDAyLW1nbXQ6fiQgLi9u
ZXRwZXJmIC1IIG5wLWNwMS1jb21wMDAwMS1ndWVzdCAtLSAtRw0KPiAxNDAwIC1QIDEyODY3IC1P
IHRocm91Z2hwdXQsdHJhbnNwb3J0X21zcyBNSUdSQVRFRCBUQ1AgU1RSRUFNIFRFU1QgZnJvbQ0K
PiAwLjAuMC4wICgwLjAuMC4wKSBwb3J0IDEyODY3IEFGX0lORVQgdG8gbnAtY3AxLWNvbXAwMDAx
LWd1ZXN0ICgpIHBvcnQgMTI4NjcNCj4gQUZfSU5FVCA6IGRlbW8gVGhyb3VnaHB1dCBUcmFuc3Bv
cnQNCj4gICAgICAgICAgICAgTVNTDQo+ICAgICAgICAgICAgIGJ5dGVzDQo+IA0KPiAzMzcyLjgy
ICAgIDEzODgNCi4uLg0KPiByb290QG5wLWNwMS1jb21wMDAwMS1tZ210Oi9ob21lL3N0YWNrIyB0
Y3BkdW1wIC1uIC1yIGZvby5wY2FwIHwgZmdyZXAgLXYNCj4gImxlbmd0aCAwIiB8IGF3ayAne3N1
bSArPSAkTkZ9RU5Ee3ByaW50ICJBdmVyYWdlOiIsc3VtL05SfScNCj4gcmVhZGluZyBmcm9tIGZp
bGUgZm9vLnBjYXAsIGxpbmstdHlwZSBFTjEwTUIgKEV0aGVybmV0KQ0KPiBBdmVyYWdlOiAyNzQx
LjkzDQoNClllcywgaXQncyBhIGtub3duIEZXIGxpbWl0YXRpb24gLSBpZiBNU1MgaXMgc21hbGxl
ciB0aGFuIGNvbmZpZ3VyZWQgTVRVLA0KYWdncmVnYXRpb24gd2lsbCBiZSBjbG9zZWQgb24gMm5k
IHBhY2tldDsgSXQgbWlnaHQgZ2V0IGNoYW5nZWQgaW4gc29tZSBmdXR1cmUNCkZXIHZlcnNpb24u
IEJ1dCBJIGFncmVlIGl0IHJlaW5mb3JjZXMgdGhlIG5lZWQgb2YgaGF2aW5nIHNvbWUga2luZCBv
Zg0KdXNlci1rbm9iIGZvciBjb250cm9sbGluZyB0aGlzIG9mZmxvYWRlZCBmZWF0dXJlLg0KDQo=
