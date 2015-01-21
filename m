From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: BW regression after "tcp: refine TSO autosizing"
Date: Wed, 21 Jan 2015 12:26:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAD027E@AcuExch.aculab.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
 <54B590FB.5040805@dev.mellanox.co.il>
 <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
 <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
 <54BC286B.8000605@mellanox.com>
 <1421720216.11734.188.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAA93jw42i37s5BJO5QJvFc=JnQBT5JsOX4QDxT6yKY3Ha3J3rg@mail.gmail.com>
 <1421723651.17892.3.camel@edumazet-glaptop2.roam.corp.google.com>
 <54BEA91D.1050001@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eyal Perry <eyalpe@mellanox.com>,
	Yuchung Cheng <ycheng@google.com>,
	"Neal Cardwell" <ncardwell@google.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>,
	"Or Gerlitz" <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	"Amir Ancel" <amira@mellanox.com>
To: 'Rick Jones' <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:53257 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbbAUM1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:27:32 -0500
In-Reply-To: <54BEA91D.1050001@hp.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogT2YgUmljayBKb25lcw0KPiA+PiBBcmUgeW91IHNheWluZyB0aGF0IGF0IGxvbmcgbGFz
dCwgZGVsYXllZCBhY2tzIGFzIHdlIGtuZXcgdGhlbSBhcmUNCj4gPj4gZGVhZCwgZGVhZCwgZGVh
ZD8NCj4gPg0KPiA+IFNvcnJ5LCBJIGNhbiBub3QgcGFyc2Ugd2hhdCB5b3UgYXJlIHNheWluZy4N
Cj4gPg0KPiA+IEluIGNhc2UgeW91IG1pc3NlZCBpdCwgaXQgaGFzIG5vdGhpbmcgdG8gZG8gd2l0
aCBkZWxheWVkIEFDSyBidXQgR1JPIG9uDQo+ID4gcmVjZWl2ZXIuDQo+IA0KPiBEYXZlIC0gYXNz
dW1pbmcgSSd2ZSBpbnRlcnByZXRlZCBFcmljJ3MgY29tbWVudHMgY29ycmVjdGx5LCBJIGJlbGll
dmUNCj4gdGhlIGFuc3dlciB0byB5b3VyIHF1ZXN0aW9uIGlzIE5vLiAgWW91ciBkZXNpcmUgZm9y
IGEgd29ybGQgYnJpbW1pbmcNCj4gd2l0aCBhY2stZXZlcnktb3RoZXIgcHVyaXR5IGhhcyBub3Qg
YmVlbiBmdWxmaWxsZWQgOikNCj4gDQo+IEhvd2V2ZXIsIHRoZSBlbmdpbmVlcnMgZm9ybWVybHkg
YXQgTWVudGF0IGFyZSBwcm9iYWJseSBwbGVhc2VkIHRoYXQgYQ0KPiBmdW5jdGlvbmFsIG5lYXIt
ZXF1aXZhbGVudCB0byB0aGVpciBBQ0sgYXZvaWRhbmNlIGhldXJpc3RpYyBoYXMgZW5kZWQtdXAN
Cj4gYmVpbmcgaW1wbGVtZW50ZWQgYW5kIHRhY2l0bHkgYWNjZXB0ZWQsIGFsYmVpdCBieSB0aGUg
YmFjayBkb29yIDopDQoNCkkgbXVzdCByZWNoZWNrIHNvbWV0aGluZyBJIGRpc2NvdmVyZWQgYSB3
aGlsZSBiYWNrIHdpdGggbW9yZSByZWNlbnQga2VybmVscy4NClRoZXJlIGhhcyBiZWVuIGEgYmFk
IGludGVyYWN0aW9uIGJldHdlZW4gJ3Nsb3cgc3RhcnQnIGFuZCAnZGVsYXllZCBhY2tzJw0Kd2hl
biBuYWdsZSBpcyBkaXNhYmxlZCBvbiAwIFJUVCBsb2NhbCBsaW5rcyB3aXRoIHVuaS1kaXJlY3Rp
b25hbCB0cmFmZmljLg0KDQonU2xvdyBzdGFydCcgd291bGQgcmVmdXNlIHRvIHNlbmQgbW9yZSB0
aGFuIDQgbWVzc2FnZXMgdW50aWwgaXQgcmVjZWl2ZWQNCmFuIGFjayAocmF0aGVyIHRoYW4gNCBt
c3Mgb2YgZGF0YSkuDQpUaGUgcmVjZWl2aW5nIHN5c3RlbSB3b3VsZG4ndCBzZW5kIGFuIGFjayB1
bnRpbCB0aGUgdGltZXIgZXhwaXJlZA0KKG9yIHNldmVyYWwgbXNzIG9mIGRhdGEgd2VyZSByZWNl
aXZlZCkgYnkgd2hpY2ggdGltZSB0aGUgc2VuZGVyIGNvdWxkIGhhdmUNCmEgbG90IG9mIGRhdGEg
cXVldWVkLg0KDQpEdWUgdG8gdGhlIDAgUlRUIGFuZCBidXJzdHkgbmF0dXJlIG9mIHRoZSBkYXRh
ICdzbG93IHN0YXJ0JyBoYXBwZW5lZA0KYWxsIHRoZSB0aW1lLg0KDQoJRGF2aWQNCg0K
