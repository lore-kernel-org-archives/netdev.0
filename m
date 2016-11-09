From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net-next 2/3] ptp: igb: Use the high resolution
 frequency method.
Date: Wed, 9 Nov 2016 21:40:04 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857C68AFE@ORSMSX115.amr.corp.intel.com>
References: <cover.1478526333.git.richardcochran@gmail.com>
 <b1d732324e0b1960b294e90ca5eb2a31b6559188.1478526333.git.richardcochran@gmail.com>
 <1478642533.7545.38.camel@intel.com>
 <20161109131146.GA6491@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>,
        "Manfred.Rudigier@omicron.at" <Manfred.Rudigier@omicron.at>,
        "ulrik.debie-os@e2big.org" <ulrik.debie-os@e2big.org>,
        "stefan.sorensen@spectralink.com" <stefan.sorensen@spectralink.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "john.stultz@linaro.org" <john.stultz@linaro.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3761 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753911AbcKIVkH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 16:40:07 -0500
In-Reply-To: <20161109131146.GA6491@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBSaWNoYXJkIENvY2hyYW4gW21h
aWx0bzpyaWNoYXJkY29jaHJhbkBnbWFpbC5jb21dDQo+IFNlbnQ6IFdlZG5lc2RheSwgTm92ZW1i
ZXIgMDksIDIwMTYgNToxMiBBTQ0KPiBUbzogS2VsbGVyLCBKYWNvYiBFIDxqYWNvYi5lLmtlbGxl
ckBpbnRlbC5jb20+DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyB0Z2x4QGxpbnV0cm9u
aXguZGU7IE1hbmZyZWQuUnVkaWdpZXJAb21pY3Jvbi5hdDsNCj4gdWxyaWsuZGViaWUtb3NAZTJi
aWcub3JnOyBzdGVmYW4uc29yZW5zZW5Ac3BlY3RyYWxpbmsuY29tOw0KPiBkYXZlbUBkYXZlbWxv
ZnQubmV0OyBLaXJzaGVyLCBKZWZmcmV5IFQgPGplZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT47
DQo+IGpvaG4uc3R1bHR6QGxpbmFyby5vcmc7IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wu
b3JnDQo+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0LW5leHQgMi8zXSBwdHA6IGlnYjogVXNlIHRo
ZSBoaWdoIHJlc29sdXRpb24gZnJlcXVlbmN5DQo+IG1ldGhvZC4NCj4gDQo+IE9uIFR1ZSwgTm92
IDA4LCAyMDE2IGF0IDEwOjAyOjIyUE0gKzAwMDAsIEtlbGxlciwgSmFjb2IgRSB3cm90ZToNCj4g
PiBPbiBUdWUsIDIwMTYtMTEtMDggYXQgMjI6NDkgKzAxMDAsIFJpY2hhcmQgQ29jaHJhbiB3cm90
ZToNCj4gPiA+IC0JcmF0ZSA9IHBwYjsNCj4gPiA+IC0JcmF0ZSA8PD0gMjY7DQo+ID4gPiAtCXJh
dGUgPSBkaXZfdTY0KHJhdGUsIDE5NTMxMjUpOw0KPiA+ID4gKwlyYXRlID0gc2NhbGVkX3BwbTsN
Cj4gPiA+ICsJcmF0ZSA8PD0gMTM7DQo+ID4gPiArCXJhdGUgPSBkaXZfdTY0KHJhdGUsIDE1NjI1
KTsNCj4gPg0KPiA+IEknbSBjdXJpb3VzIGhvdyB5b3UgZ2VuZXJhdGUgdGhlIG5ldyBtYXRoIGhl
cmUsIHNpbmNlIHRoaXMgY2FuIGJlDQo+ID4gdHJpY2t5LCBhbmQgSSBjb3VsZCB1c2UgbW9yZSBl
eGFtcGxlcyBpbiBvcmRlciB0byBwb3J0IHRvIHNvbWUgb2YgdGhlDQo+ID4gb3RoZXIgZHJpdmVy
cyBpbXBsZW1lbnRhdGlvbnMuIEknbSBub3QgcXVpdCBzdXJlIGhvdyB0byBoYW5kbGUgdGhlDQo+
ID4gdmFsdWUgd2hlbiB0aGUgbG93ZXIgMTYgYml0cyBhcmUgZnJhY3Rpb25hbC4NCj4gDQo+IFRM
O0RSIHZlcnNpb246DQo+IA0KPiBJbiBwdHBfY2xvY2suYyB3ZSBjb252ZXJ0IHNjYWxlZF9wcG0g
dG8gcHBiIGxpa2UgdGhpcy4NCj4gDQo+IAlwcGIgPSBzY2FsZWRfcHBtICogMTBeMyAqIDJeLTE2
DQo+IA0KPiBJZiB5b3UgYWxyZWFkeSBoYXZlIGEgd29ya2luZyBkcml2ZXIgdGhhdCBkb2VzDQo+
IA0KPiAJcmVndmFsID0gcHBiICogU09NRU1BVEg7DQo+IA0KPiB0aGVuIGp1c3Qgc3Vic3RpdHV0
ZQ0KPiANCj4gCXJlZ3ZhbCA9IChzY2FsZWRfcHBtICogMTBeMyAqIDJeLTE2KSAqIFNPTUVNQVRI
Ow0KPiAJICAgICAgID0gKHNjYWxlZF9wcG0gKiAgNV4zICogMl4tMTMpICogU09NRU1BVEg7DQo+
IA0KPiBhbmQgc2ltcGxpZnkgYnkgY29tYmluaW5nIHRoZSA1XjMgYW5kIDJeLTEzIGNvbnN0YW50
cyBpbnRvIFNPTUVNQVRILg0KPiANCg0KVGhhbmtzLCB0aGlzIG1ha2VzIG1vcmUgc2Vuc2UgOikN
Cg0KPiBMb25nZXIgZXhwbGFuYXRpb246DQo+IA0KPiBZb3UgaGF2ZSB0byBjb25zaWRlciBob3cg
dGhlIGZyZXF1ZW5jeSBhZGp1c3RtZW50IEhXIHdvcmtzLCBjYXNlIGJ5DQo+IGNhc2UuICBCb3Ro
IHRoZSBpMjEwIGFuZCB0aGUgcGh5dGVyIGhhdmUgYW4gYWRqdXN0bWVudCByZWdpc3RlciB0aGF0
DQo+IGhvbGRzIHVuaXRzIG9mIDJeLTMyIG5hbm9zZWNvbmRzIHBlciA4IG5hbm9zZWNvbmQgY2xv
Y2sgcGVyaW9kLCBhbmQgc28NCj4gdGhlIHJhdGUgZnJvbSBhZGp1c3RtZW50IHZhbHVlIDEgaXMg
KDJeLTMyIC8gOCkuDQo+IA0KPiBUaGVuIHdpdGggdGhlIG9sZCBpbnRlcmZhY2UsIHRoZSBjb252
ZXJzaW9uIGZyb20gImFkanVzdG1lbnQgdW5pdCIgdG8NCj4gcHBiIHdhcyAoMl4tMzIgLyA4ICog
MTBeOSkgb3IgKDJeLTI2ICogNV45KS4gIFRoZSBjb252ZXJzaW9uIHRoZSBvdGhlcg0KPiB3YXkg
bmVlZHMgdGhlIGludmVyc2UsIGFuZCBzbyB0aGUgY29kZSBkaWQgKHBwYiA8PCAyNikgLyA1Xjku
DQo+IA0KPiBXaXRoIHRoZSBuZXcgaW50ZXJmYWNlLCB0aGUgY29udmVyc2lvbiBmcm9tICJhZGp1
c3RtZW50IHVuaXQiIHRvDQo+IHNjYWxlZF9wcG0gaXMgKDJeLTMyIC8gOCAqIDEwXjYgKiAyXjE2
KSBvciAoMl4tMTMgKiA1XjYpLiAgVGhlIGNvZGUNCj4gY29udmVydHMgdGhlIG90aGVyIGRpcmVj
dGlvbiB1c2luZyB0aGUgaW52ZXJzZSwgKHNfcHBtIDw8IDEzKSAvIDVeNi4NCj4gDQoNClJpZ2h0
LiBUaGlzIGhlbHBzLg0KDQpUaGFua3MsDQpKYWtlDQoNCj4gSFRILA0KPiBSaWNoYXJkDQo=
