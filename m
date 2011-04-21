From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: rtnetlink and many VFs
Date: Thu, 21 Apr 2011 11:28:54 -0700
Message-ID: <43F901BD926A4E43B106BF17856F07550145FC763B@orsmsx508.amr.corp.intel.com>
References: <1303396576.3165.13.camel@bwh-desktop>
	 <43F901BD926A4E43B106BF17856F07550145FC7526@orsmsx508.amr.corp.intel.com>
	 <1303407628.3165.30.camel@bwh-desktop>
	 <43F901BD926A4E43B106BF17856F07550145FC75D6@orsmsx508.amr.corp.intel.com>
 <1303409517.3165.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11565 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750887Ab1DUS24 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 14:28:56 -0400
In-Reply-To: <1303409517.3165.39.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5r
ZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LW93bmVyQHZnZXIua2VybmVsLm9yZ10NCj4gT24gQmVo
YWxmIE9mIEJlbiBIdXRjaGluZ3MNCj4gU2VudDogVGh1cnNkYXksIEFwcmlsIDIxLCAyMDExIDEx
OjEyIEFNDQo+IFRvOiBSb3NlLCBHcmVnb3J5IFYNCj4gQ2M6IERhdmlkIE1pbGxlcjsgbmV0ZGV2
OyBzZi1saW51eC1kcml2ZXJzDQo+IFN1YmplY3Q6IFJFOiBydG5ldGxpbmsgYW5kIG1hbnkgVkZz
DQo+IA0KPiBPbiBUaHUsIDIwMTEtMDQtMjEgYXQgMTA6NTAgLTA3MDAsIFJvc2UsIEdyZWdvcnkg
ViB3cm90ZToNCj4gPiA+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+ID4gPiBGcm9tOiBC
ZW4gSHV0Y2hpbmdzIFttYWlsdG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0NCj4gPiA+IFNl
bnQ6IFRodXJzZGF5LCBBcHJpbCAyMSwgMjAxMSAxMDo0MCBBTQ0KPiA+ID4gVG86IFJvc2UsIEdy
ZWdvcnkgVg0KPiA+ID4gQ2M6IERhdmlkIE1pbGxlcjsgbmV0ZGV2OyBzZi1saW51eC1kcml2ZXJz
DQo+ID4gPiBTdWJqZWN0OiBSRTogcnRuZXRsaW5rIGFuZCBtYW55IFZGcw0KPiA+ID4NCj4gDQo+
ID4gSSBzdGlsbCBmZWVsIGxpa2UgZXZlbnR1YWxseSB0aGUgbnVtYmVyIG9mIFZGcyB3aWxsIG91
dGdyb3cgdGhlDQo+ID4gY2FwYWJpbGl0eSBvZiBhIHNpbmdsZSBtZXNzYWdlIHRvIGhhbmRsZSwg
ZXNwZWNpYWxseSB3aGVuIFZGcyB3aWxsDQo+ID4gaGF2ZSB0aGUgY2FwYWJpbGl0eSBvZiBoYXZp
bmcgbXVsdGlwbGUgTUFDIGFkZHJlc3MgYW5kIFZMQU4gZmlsdGVycw0KPiA+IGFzc2lnbmVkIHRv
IHRoZW0uICBBbmQgaXQgc2VlbXMgb3J0aG9nb25hbCB0byBtZSB0byBtaXJyb3IgdGhlICdpcA0K
PiA+IGxpbmsgc2V0IGV0aCh4KSB2ZiAobiknIHN5bnRheCB3aXRoIGEgJ2lwIGxpbmsgc2hvdyBl
dGgoeCkgdmYgKG4pJw0KPiA+IHN5bnRheC4NCj4gPg0KPiA+IFRoYXQncyBqdXN0IG1lIHRob3Vn
aC4NCj4gWy4uLl0NCj4gDQo+IEkgdGhpbmsgaXQgd291bGQgYmUgYSB1c2VmdWwgZXh0ZW5zaW9u
LCBidXQgd2UgaGF2ZSB0byBrZWVwIHRoZSBjdXJyZW50DQo+IEFQSSB3b3JraW5nIGFzIGZhciBh
cyBwb3NzaWJsZS4NCg0KU3VyZSwgc291bmRzIGdvb2QuICBJJ20gIHdvcmtpbmcgb24gc29tZXRo
aW5nIHRoYXQgd2lsbCBwYXRjaCB0aGluZ3MgdXAgZm9yIHRoZSBwcmVzZW50IHVzZSBjYXNlIHJp
Z2h0IG5vdy4NCg0KLSBHcmVnDQoNCg==
