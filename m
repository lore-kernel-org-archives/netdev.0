From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [PATCH v2] ethtool: check size of user memory before copying
 strings and stats
Date: Tue, 1 Mar 2016 22:58:26 +0000
Message-ID: <1456873105.9520.19.camel@intel.com>
References: <1456871112-14103-1-git-send-email-jacob.e.keller@intel.com>
	 <CAKgT0UdDQ0_HEhOQRew20V-MYKDDWbNZRZDFwNLz47cQX03dYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Rustad, Mark D" <mark.d.rustad@intel.com>,
	"mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>
To: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19930 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750998AbcCAW62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 17:58:28 -0500
In-Reply-To: <CAKgT0UdDQ0_HEhOQRew20V-MYKDDWbNZRZDFwNLz47cQX03dYg@mail.gmail.com>
Content-Language: en-US
Content-ID: <BAE7DFA666B05C4E8F3CC7368307E99D@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE2LTAzLTAxIGF0IDE0OjMxIC0wODAwLCBBbGV4YW5kZXIgRHV5Y2sgd3JvdGU6
DQo+IFRoaXMgc3RpbGwgaGFzIHRoZSBwb3RlbnRpYWwgdG8gcHJvdmlkZSBnYXJiYWdlIGRhdGEu
wqDCoFdoYXQgeW91DQo+IHNob3VsZA0KPiBwcm9iYWJseSBkbyBhdCBlYWNoIHN0YWdlIGlzIG1h
a2Ugc3VyZSB0aGUgbGVuZ3RoIG1hdGNoZXMgd2l0aCB0aGUNCj4gZXhhY3QgdmFsdWUgdGhhdCB5
b3Ugd291bGQgZXhwZWN0Lg0KPiANCg0KU3VyZSwgYW4gZXhhY3QgY2hlY2sgY291bGQgYmUgZG9u
ZSBpbnN0ZWFkLCBob3dldmVyLi4uDQoNCj4gSSBhc3N1bWUgeW91IGNhbm5vdCBoYXZlIGFueSBm
aWVsZHMgc2h1ZmZsZSBvbiB5b3U/wqDCoFdoYXQgSSBtZWFuIGJ5DQo+IHRoYXQgaXMgdGhhdCB5
b3UgZG9uJ3Qgd2FudCB0byBoYXZlIGEgc2V0dXAgd2l0aCA0IFR4IGFuZCA0IFJ4IHJpbmdzDQo+
IHdoZXJlIHlvdSB0aGVuIHJlcGxhY2UgaXQgd2l0aCAxIFR4IGFuZCA3IFJ4IHJpbmdzIGFuZCB0
cnkgdG8NCj4gcG9wdWxhdGUNCj4gdGhlIHNhbWUgZGF0YSBpbnRvIGEgc2V0dXAgd2hlcmUgdGhl
IHN0cmluZ3MgcmVwb3J0ZWQgYXJlIGZvciA0IFR4DQo+IGFuZA0KPiA0IFJ4LsKgwqBZb3Ugc2hv
dWxkIGRvdWJsZSBjaGVjayB0aGF0IHRoZSBsZW5ndGggY2FuIGJlIHVzZWQgYXMgYSBtZWFucw0K
PiBvZiBpZGVudGlmeWluZyBleGFjdGx5IHdoYXQgc3RyaW5ncyB3aWxsIGJlIHdoZXJlLg0KPiAN
Cj4gLSBBbGV4DQoNCg0KRGFybi4gTG9va3MgbGlrZSB5b3UncmUgcmlnaHQuIEl0IHdvdWxkIGJl
IHRoZW9yZXRpY2FsbHkgcG9zc2libGUgZm9yDQp0aGUgbnVtYmVyIG9mIHF1ZXVlcyAob3Igb3Ro
ZXIgdmFyaWFibGVzKSB0byBjaGFuZ2Ugc3VjaCB0aGF0IHRoZSBzaXplDQptYXRjaGVzIGJ1dCB0
aGUgZGF0YSBubyBsb25nZXIgbGluZXMgdXAgYWdhaW5zdCB0aGUgc3RyaW5ncy4NCg0KRm9yIHF1
ZXVlcywgSSBkb24ndCB0aGluayB3ZSdyZSB2dWxuZXJhYmxlIG9uIHRoZSBmbTEwayBkcml2ZXIs
IGJlY2F1c2UNCndlIG9ubHkgdXNlIGNvbWJpbmVkIHF1ZXVlcy4gSG93ZXZlciwgd2UgYWxyZWFk
eSBoYXZlIHN1cHBvcnQgZm9yDQoiZGVidWctc3RhdGlzdGljcyIgd2hpY2ggc2hvd3MgZXh0cmEg
c3RhdHMgcGx1cyBzb21lIHN0YXRzIHBlciB2aXJ0dWFsDQpmdW5jdGlvbi4gSSBhbSBub3Qgc3Vy
ZSBpZiB0aGVzZSBjb3VsZCBjaGFuZ2Ugd2l0aGluIHRoZSB0aW1lIHdpbmRvdyB0bw0KcmVzdWx0
IGluIGdhcmJhZ2UgZGF0YS4NCg0KSSBkb24ndCBrbm93IGhvdyBtdWNoIG9mIGEgcmVhbCB3b3Js
ZCBwcm9ibGVtIHRoaXMgd291bGQgYmUgdGhvdWdoLg0KDQpJJ20gZ3Vlc3NpbmcgaXQncyBtb3Jl
IHJlYXNvbiB0byBwcm9tb3RlIHRoZSBpZGVhIG9mIGNvbnZlcnRpbmcgdG8gc29tZQ0KbmV3IHRv
b2wgYmFzZWQgb24gbmV0bGluay4NCg0KVGhhbmtzLA0KSmFrZQ==
