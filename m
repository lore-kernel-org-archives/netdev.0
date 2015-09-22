From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH net-next 4/7] bridge: define some min/max ageing time
 constants we'll use next
Date: Tue, 22 Sep 2015 08:28:27 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9F1222@SJEXCHMB14.corp.ad.broadcom.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
 <1442606151-50429-5-git-send-email-sfeldma@gmail.com>
 <20150919064507.GD2067@nanopsycho.orion>
 <CAE4R7bDeXC0+P5zmgiD+MfQ_6hzujdS-+PBh6d6ox7-pNoSuag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Netdev <netdev@vger.kernel.org>,
	Siva Mannem <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"Florian Fainelli" <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:59426 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757709AbbIVI2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 04:28:30 -0400
In-Reply-To: <CAE4R7bDeXC0+P5zmgiD+MfQ_6hzujdS-+PBh6d6ox7-pNoSuag@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogU2NvdHQgRmVsZG1hbiBb
bWFpbHRvOnNmZWxkbWFAZ21haWwuY29tXQ0KPiBTZW50OiBTYXR1cmRheSwgU2VwdGVtYmVyIDE5
LCAyMDE1IDEwOjUxIFBNDQo+IFRvOiBKaXJpIFBpcmtvDQo+IENjOiBOZXRkZXY7IFNpdmEgTWFu
bmVtOyBQcmVta3VtYXIgSm9ubmFsYTsgc3RlcGhlbkBuZXR3b3JrcGx1bWJlci5vcmc7DQo+IFJv
b3BhIFByYWJodTsgYW5kcmV3QGx1bm4uY2g7IEZsb3JpYW4gRmFpbmVsbGk7IFZpdmllbiBEaWRl
bG90DQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHQgNC83XSBicmlkZ2U6IGRlZmluZSBz
b21lIG1pbi9tYXggYWdlaW5nIHRpbWUNCj4gY29uc3RhbnRzIHdlJ2xsIHVzZSBuZXh0DQo+IA0K
PiBPbiBGcmksIFNlcCAxOCwgMjAxNSBhdCAxMTo0NSBQTSwgSmlyaSBQaXJrbyA8amlyaUByZXNu
dWxsaS51cz4gd3JvdGU6DQo+ID4gRnJpLCBTZXAgMTgsIDIwMTUgYXQgMDk6NTU6NDhQTSBDRVNU
LCBzZmVsZG1hQGdtYWlsLmNvbSB3cm90ZToNCj4gPj5Gcm9tOiBTY290dCBGZWxkbWFuIDxzZmVs
ZG1hQGdtYWlsLmNvbT4NCj4gPj4NCj4gPj5TaWduZWQtb2ZmLWJ5OiBTY290dCBGZWxkbWFuIDxz
ZmVsZG1hQGdtYWlsLmNvbT4NCj4gPj4tLS0NCj4gPj4gaW5jbHVkZS9saW51eC9pZl9icmlkZ2Uu
aCB8ICAgIDQgKysrKw0KPiA+PiAxIGZpbGUgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspDQo+ID4+
DQo+ID4+ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvaWZfYnJpZGdlLmggYi9pbmNsdWRlL2xp
bnV4L2lmX2JyaWRnZS5oDQo+ID4+aW5kZXggZGFkOGIwMC4uNmNjNmRiYyAxMDA2NDQNCj4gPj4t
LS0gYS9pbmNsdWRlL2xpbnV4L2lmX2JyaWRnZS5oDQo+ID4+KysrIGIvaW5jbHVkZS9saW51eC9p
Zl9icmlkZ2UuaA0KPiA+PkBAIC00Niw2ICs0NiwxMCBAQCBzdHJ1Y3QgYnJfaXBfbGlzdCB7DQo+
ID4+ICNkZWZpbmUgQlJfTEVBUk5JTkdfU1lOQyAgICAgIEJJVCg5KQ0KPiA+PiAjZGVmaW5lIEJS
X1BST1hZQVJQX1dJRkkgICAgICBCSVQoMTApDQo+ID4+DQo+ID4+Ky8qIHZhbHVlcyBhcyBwZXIg
aWVlZTgwMjFRQnJpZGdlRmRiQWdpbmdUaW1lICovDQo+ID4+KyNkZWZpbmUgQlJfTUlOX0FHRUlO
R19USU1FICAgICgxMCAqIEhaKQ0KPiA+PisjZGVmaW5lIEJSX01BWF9BR0VJTkdfVElNRSAgICAo
MTAwMDAwMCAqIEhaKQ0KPiA+DQo+ID4gSSB0aGluayB0aGF0IGEgYnJpZGdlIHBhdGNoIGNoZWNr
aW5nIGFnYWluc3QgdGhlc2UgdmFsdWVzIHNob3VsZCBiZQ0KPiA+IGludHJvZHVjZWQgYWxvbmcg
d2l0aCB0aGVzZSB2YWx1ZXMsIGluIHRoZSBzYW1lIHBhdGNoc2V0DQo+IA0KPiBJIG5lZWQgdGhl
IE1JTiB2YWx1ZSBmb3IgdGhpcyBwYXRjaHNldCBpbiByb2NrZXIncyBhZ2VpbmcgdGltZXIsIHNv
DQo+IGl0J3MgaW50cm9kdWNlZCBoZXJlLiAgTUlOL01BWCB3aWxsIGJlIHVzZWQgYWdhaW4gaW4g
Zm9sbG93LW9uIHBhdGNoDQo+IFByZW0gaXMgZ29pbmcgdG8gc2VuZCB0byByYW5nZSBjaGVjayB1
c2VyIGlucHV0Lg0KDQpBY2sgdGhhdC4gIEkgd2lsbCBhZGQgdGhvc2UgY2hlY2tzIGFzIHBhcnQg
b2YgdGhlIHBhdGNoIGZvciBpcHJvdXRlMi4NCg0KLVByZW0NCg==
