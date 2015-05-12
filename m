From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/6] net: Add a struct net parameter to sock_create_kern
Date: Tue, 12 May 2015 13:16:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB338CF@AcuExch.aculab.com>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
 <87wq0kcqlm.fsf@x220.int.ebiederm.org>
 <20150508140733.GA13325@gondor.apana.org.au>
 <87sib76kef.fsf@x220.int.ebiederm.org>
 <20150509011339.GA19116@gondor.apana.org.au>
 <87383633pu.fsf_-_@x220.int.ebiederm.org>
 <87oalu1p16.fsf_-_@x220.int.ebiederm.org>
 <063D6719AE5E284EB5DD2968C1650D6D1CB33641@AcuExch.aculab.com>
 <110296A8-1CC9-456C-B126-50C90D4E3E17@xmission.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB33707@AcuExch.aculab.com>
 <5551F205.1080707@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ying Xue <ying.xue@windriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"cwang@twopensource.com" <cwang@twopensource.com>,
	"xemul@openvz.org" <xemul@openvz.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"maxk@qti.qualcomm.com" <maxk@qti.qualcomm.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"jchapman@katalix.com" <jchapman@katalix.com>,
	"erik.hugne@ericsson.com" <erik.hugne@ericsson.com>,
	"jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
	"horms@verge.net.au" <horms@verge.net.au>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "'nicolas.dichtel@6wind.com'" <nicolas.dichtel@6wind.com>,
	"'Eric W. Biederman'" <ebiederm@xmission.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.190]:57698 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932537AbbELNSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 09:18:05 -0400
In-Reply-To: <5551F205.1080707@6wind.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTmljb2xhcyBEaWNodGVsIFttYWlsdG86bmljb2xhcy5kaWNodGVsQDZ3aW5kLmNvbV0N
Cj4gU2VudDogMTIgTWF5IDIwMTUgMTM6MjkNCj4gTGUgMTIvMDUvMjAxNSAxMzo0OCwgRGF2aWQg
TGFpZ2h0IGEgw6ljcml0IDoNCj4gPiBGcm9tOiBFcmljIFcuIEJpZWRlcm1hbg0KPiA+PiBTZW50
OiAxMiBNYXkgMjAxNSAwOTo1NQ0KPiA+Pg0KPiA+PiBPbiBNYXkgMTIsIDIwMTUgMzoyNDoxMSBB
TSBDRFQsIERhdmlkIExhaWdodCA8RGF2aWQuTGFpZ2h0QEFDVUxBQi5DT00+IHdyb3RlOg0KPiA+
IC4uLg0KPiA+Pj4gV291bGRuJ3QgaXQgaW52b2x2ZSBmYXIgbGVzcyBjaHVybiB0byBhZGQgYSBu
ZXcgZnVuY3Rpb24gdGhhdCB1c2VzIGENCj4gPj4+IG5vbi1kZWZhdWx0IG5hbWVzcGFjZT8NCj4g
Pj4NCj4gPj4gVGhlIGdvYWwgaXMgY29tcHJlaGVuc2libGUgYW5kIG1haW50YWluYWJsZSBrZXJu
ZWwgY29kZS4NCj4gPj4NCj4gPj4gV2hpY2ggbmV0d29yayBuYW1lc3BhY2UgeW91ciBzb2NrZXQg
aXMgaW4sIGlzIGFuIGltcG9ydGFudCBwcm9wZXJ0eSBhbmQgc29tZXRoaW5nIHlvdSBwcm9iYWJs
eSBjYXJlDQo+ID4+IGFib3V0IGlmIHlvdSBhcmUgY3JlYXRpbmcga2VybmVsIHNvY2tldHMuDQo+
ID4NCj4gPiBUaGF0IHJhdGhlciBkZXBlbmRzIG9uIHdoZXRoZXIgeW91J3ZlIGFueXdoZXJlIHRv
IGdldCBhIG5hbWVzcGFjZSBmcm9tLg0KPiA+IGVnIHNvbWV0aGluZyBsaWtlIGNlcGgvbWVzc2Vu
Z2VyLmMNCj4gc2tfbmV0KGNvbi0+c29jay0+c2spPw0KDQpXaGF0IGlmIHlvdSBkb24ndCBhbHJl
YWR5IGhhdmUgYSBzb2NrZXQ/DQpKdXN0IGFuIElQKHY2KSBhZGRyZXNzID8NCg0KPiBUaGlzIHBh
cmFtZXRlciBpcyBlc3NlbnRpYWwsIGhpZGluZyBpdCB3aWxsIGp1c3QgaGlkZXMgYnVncy4NCj4g
SGF2aW5nIHRoaXMgcGFyYW1ldGVyIGZvcmNlcyB0aGUgZGV2ZWxvcGVyIHRvIGFzayBoaW1zZWxm
IHdoYXQgaXMgdGhlIGJlc3QNCj4gdmFsdWUuDQoNCldoYXQgaWYgdGhlIGFuc3dlciBpcyAnTkZJ
Jz8NCldoaWNoIHJlcXVpcmVzIHRoZSBhbnN3ZXIgYmUgcHVzaGVkIGJhY2sgdG8gdGhlICdhcHBs
aWNhdGlvbicgY29uZmlndXJhdGlvbj8NCk1vc3QgdXNlcnMgd2lsbCBoYXZlIG5vIGlkZWEgZWl0
aGVyLg0KDQoJRGF2aWQNCg==
