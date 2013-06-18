From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH net-next 1/2] bnx2x: add support for ndo_ll_poll
Date: Tue, 18 Jun 2013 12:11:46 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F20CBC47B@SJEXCHMB06.corp.ad.broadcom.com>
References: <1371541333-19225-1-git-send-email-dmitry@broadcom.com>
 <1371541333-19225-2-git-send-email-dmitry@broadcom.com>
 <1371543058.3252.214.camel@edumazet-glaptop>
 <504C9EFCA2D0054393414C9CB605C37F20CBC237@SJEXCHMB06.corp.ad.broadcom.com>
 <1371554143.3252.253.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4608 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755961Ab3FRMLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 08:11:53 -0400
In-Reply-To: <1371554143.3252.253.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiBUdWVzZGF5LCBKdW5lIDE4LCAyMDEz
IDI6MTYgUE0NCj4gVG86IERtaXRyeSBLcmF2a292DQo+IENjOiBkYXZlbUBkYXZlbWxvZnQubmV0
OyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBFaWxvbiBHcmVlbnN0ZWluDQo+IFN1YmplY3Q6IFJF
OiBbUEFUQ0ggbmV0LW5leHQgMS8yXSBibngyeDogYWRkIHN1cHBvcnQgZm9yIG5kb19sbF9wb2xs
DQo+IA0KPiBPbiBUdWUsIDIwMTMtMDYtMTggYXQgMTA6NDUgKzAwMDAsIERtaXRyeSBLcmF2a292
IHdyb3RlOg0KPiANCj4gPiA+IElkZWFsbHksIHdlIGNvdWxkIGtlZXAgYSBjb3VudGVyIG9mIGVu
YWJsZWQgTExTIHNvY2tldHMsIHRvDQo+ID4gPiBhdXRvbWF0aWNhbGx5IHN3aXRjaCBvZmYvb24g
R1JPLCBidXQgaW4gbmV0L2NvcmUsIG5vdCBpbiBldmVyeSBkcml2ZXIuDQo+ID4NCj4gPiBTaW5j
ZSB3ZSBoYXZlIEdSTyBpbiBGVyBpdCB3aWxsIGJlIGhhcmQgdG8gZGlzYWJsZS9lbmFibGUgaXQg
b24gdGhlIGZseSwgcHJvYmFibHkgYmV0dGVyICB0byByZXR1cm4gTExfRkxVU0hfRkFJTEVEIHdo
ZW4gR1JPIGlzDQo+IGVuYWJsZWQ/DQo+IA0KPiBZZXMsIGFzc3VtaW5nIEdSTyBpbiBGVyBtZWFu
cyBsYXRlbmNpZXMgPw0KPiANCj4gKElmIHdlIHJlY2VpdmUgYSBmcmFtZSwgRlcgaGFzIHRvIHdh
aXQgYSBiaXQgZm9yIHRoZSBmb2xsb3dpbmcgZnJhbWVzIHRvDQo+IGV2ZW50dWFsbHkgYWdncmVn
YXRlIHRoZW0pDQpUaGF0J3MgdHJ1ZSAhDQoNCkJ1dCBwcm9ibGVtIGlzIHRoYXQgaW4gZGlzYWJs
aW5nIHRoZSBmZWF0dXJlIG9uIHRoZSBmbHkgd2lsbCBiZSB2ZXJ5IFNsb3dQYXRoIG9wZXJhdGlv
biwgd2hpY2ggY2FuJ3QgYmUgZG9uZSBmcm9tIHBvbGwgY2FsbGJhY2suLi4NCg0KPiANCj4gSSB0
aG91Z2h0IEZXIGRpZCBMUk8gcGFydCBvbiBibngyeCwgYW5kIEdSTyB3YXMgdGhlIHNvZnR3YXJl
IHRoaW5nIChpbg0KPiBuZXR3b3JraW5nIGNvcmUsIG5vdCBpbiB0aGUgYm54MnggZHJpdnJlKQ0K
DQpMUk8gaGFzIHByaW9yaXR5IG92ZXIgR1JPLCB3aGVuIExSTyBpcyBkaXNhYmxlZCBibngyeCBG
VyBwcm92aWRlcyBmdWxseSBHUk8tY29tcGxhaW50ICBhZ2dyZWdhdGlvbnMsDQp3aGljaCBhcmUg
cmVhZHkgZm9yIGZvcndhcmRpbmcgd2l0aG91dCBob3N0IGNwdSBpbnRlcnZlbnRpb24uLi4gDQoN
Cj4gDQo+IA0KPiANCg0K
