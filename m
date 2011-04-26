From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Tue, 26 Apr 2011 14:58:57 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755018DC49C1B@orsmsx508.amr.corp.intel.com>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	 <1303799597.2747.214.camel@edumazet-laptop>
	 <20110425.235600.104065244.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
	 <1303834864.3358.58.camel@edumazet-laptop>
	 <43F901BD926A4E43B106BF17856F0755018DC497F8@orsmsx508.amr.corp.intel.com>
 <1303844836.2850.6.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:31092 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932957Ab1DZV7W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 17:59:22 -0400
In-Reply-To: <1303844836.2850.6.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWls
dG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0NCj4gU2VudDogVHVlc2RheSwgQXByaWwgMjYs
IDIwMTEgMTI6MDcgUE0NCj4gVG86IFJvc2UsIEdyZWdvcnkgVjsgRXJpYyBEdW1hemV0DQo+IENj
OiBEYXZpZCBNaWxsZXI7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUkU6IFtS
RkMgUEFUQ0hdIG5ldGxpbms6IEluY3JlYXNlIG5ldGxpbmsgZHVtcCBza2IgbWVzc2FnZSBzaXpl
DQo+IA0KPiBPbiBUdWUsIDIwMTEtMDQtMjYgYXQgMDk6MjQgLTA3MDAsIFJvc2UsIEdyZWdvcnkg
ViB3cm90ZToNCj4gPiA+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gPiBGcm9tOiBF
cmljIER1bWF6ZXQgW21haWx0bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiA+ID4gU2VudDog
VHVlc2RheSwgQXByaWwgMjYsIDIwMTEgOToyMSBBTQ0KPiA+ID4gVG86IFJvc2UsIEdyZWdvcnkg
Vg0KPiA+ID4gQ2M6IERhdmlkIE1pbGxlcjsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsgYmh1dGNo
aW5nc0Bzb2xhcmZsYXJlLmNvbQ0KPiA+ID4gU3ViamVjdDogUkU6IFtSRkMgUEFUQ0hdIG5ldGxp
bms6IEluY3JlYXNlIG5ldGxpbmsgZHVtcCBza2IgbWVzc2FnZQ0KPiBzaXplDQo+ID4gPg0KPiA+
ID4gTGUgbWFyZGkgMjYgYXZyaWwgMjAxMSDDoCAwOToxMiAtMDcwMCwgUm9zZSwgR3JlZ29yeSBW
IGEgw6ljcml0IDoNCj4gPiA+DQo+ID4gPiA+IEknbSBmaW5lIHdpdGggaG93ZXZlciB5b3UgZm9s
a3Mgd2FudCB0byBhcHByb2FjaCB0aGlzLCBqdXN0IGdpdmUgbWUNCj4gc29tZQ0KPiA+ID4gZGly
ZWN0aW9uLg0KPiA+ID4NCj4gPiA+IEkgd291bGQganVzdCB0cnkgZm9sbG93aW5nIHBhdGNoIDoN
Cj4gPg0KPiA+IEknbGwgdGVzdCBpdCBvdXQsIGl0J3MgY2VydGFpbmx5IGEgbG90IHNpbXBsZXIu
ICBQZXJoYXBzIEkgd2FzIGdldHRpbmcgYQ0KPiBiaXQgdG9vIGZhbmN5Lg0KPiA+DQo+ID4gQmVu
IHdvdWxkIHdhbnQgdG8gbWFrZSBzdXJlIGl0IHdvcmtzIGZvciAxMjcgVkZzLCBteSBkZXZpY2Ug
ZG9lcyA2My4NCj4gDQo+IEkgaGF2ZW4ndCBiZWVuIHdvcmtpbmcgb24gU1ItSU9WIG15c2VsZiBz
byBJJ2xsIHBhc3MgdGhpcyBvbiB0byBhDQo+IGNvbGxlYWd1ZS4gIFRoYW5rcywgRXJpYy4NCg0K
RXJpYydzIHBhdGNoIHdvcmtzIGZpbmUgZm9yIHRoZSBjYXNlIG9mIDYzIFZGcy4gIEZvciBtb3N0
IGR1bXBzIGl0J3MgYWxsb2NhdGluZyBxdWl0ZSBhIGJpdCBtb3JlIG1lbW9yeSB0aGFuIG5lY2Vz
c2FyeSBidXQgdGhhdCdzIG5vdCBhIGJpZyBpc3N1ZSBzaW5jZSBpdCdzIHRyYW5zaWVudCBhbmQg
bm90IGhlbGQgZm9yIGxvbmcuDQoNCi0gR3JlZw0KDQoNCg==
