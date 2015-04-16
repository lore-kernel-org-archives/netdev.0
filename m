From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] "tcp: refine TSO autosizing" causes performance
 regression on Xen
Date: Thu, 16 Apr 2015 09:22:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1F43C@AcuExch.aculab.com>
References: <alpine.DEB.2.02.1504091344260.7690@kaball.uk.xensource.com>
	 <1428596218.25985.263.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.02.1504091729160.7690@kaball.uk.xensource.com>
	 <CAFLBxZaVjFHh4UBnksGZS4waBr4jLdO8aJegyKvsU1-TvVt2Dg@mail.gmail.com>
	 <1428932970.3834.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAFLBxZYt7-v29ysm=f+5QMOw64_QhESjzj98udba+1cS-PfObA@mail.gmail.com>
	 <1429115934.7346.107.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552E9E8D.1080000@eu.citrix.com>
	 <1429118948.7346.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA2BC.5000707@eu.citrix.com>
	 <1429120373.7346.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552EA844.5010308@eu.citrix.com>
 <1429121979.7346.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <552F7936.9070205@eu.citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jonathan Davies <Jonathan.Davies@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"Stefano Stabellini" <stefano.stabellini@eu.citrix.com>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Paul Durrant" <paul.durrant@citrix.com>,
	Christoffer Dall <christoffer.dall@linaro.org>,
	Felipe Franciosi <felipe.franciosi@citrix.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Vrabel <david.vrabel@citrix.com>
To: 'George Dunlap' <george.dunlap@eu.citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <552F7936.9070205@eu.citrix.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogR2VvcmdlIER1bmxhcA0KPiBTZW50OiAxNiBBcHJpbCAyMDE1IDA5OjU2DQo+IE9uIDA0
LzE1LzIwMTUgMDc6MTkgUE0sIEVyaWMgRHVtYXpldCB3cm90ZToNCj4gPiBPbiBXZWQsIDIwMTUt
MDQtMTUgYXQgMTk6MDQgKzAxMDAsIEdlb3JnZSBEdW5sYXAgd3JvdGU6DQo+ID4NCj4gPj4gTWF5
YmUgeW91IHNob3VsZCBzdG9wIHdhc3RpbmcgYWxsIG9mIG91ciB0aW1lIGFuZCBqdXN0IHRlbGwg
dXMgd2hhdA0KPiA+PiB5b3UncmUgdGhpbmtpbmcuDQo+ID4NCj4gPiBJIHRoaW5rIHlvdSBtYWtl
IG1lIHdhc3RpbmcgbXkgdGltZS4NCj4gPg0KPiA+IEkgYWxyZWFkeSBnYXZlIGFsbCB0aGUgaGlu
dHMgaW4gcHJpb3IgZGlzY3Vzc2lvbnMuDQo+IA0KPiBSaWdodCwgYW5kIEkgc3VnZ2VzdGVkIHRo
ZXNlIHR3byBvcHRpb25zOg0KPiANCj4gIk9idmlvdXNseSBvbmUgc29sdXRpb24gd291bGQgYmUg
dG8gYWxsb3cgdGhlIGRyaXZlcnMgdGhlbXNlbHZlcyB0byBzZXQNCj4gdGhlIHRjcF9saW1pdF9v
dXRwdXRfYnl0ZXMsIGJ1dCB0aGF0IHNlZW1zIGxpa2UgYSBtYWludGVuYW5jZQ0KPiBuaWdodG1h
cmUuDQo+IA0KPiAiQW5vdGhlciBzaW1wbGUgc29sdXRpb24gd291bGQgYmUgdG8gYWxsb3cgZHJp
dmVycyB0byBpbmRpY2F0ZSB3aGV0aGVyDQo+IHRoZXkgaGF2ZSBhIGhpZ2ggdHJhbnNtaXQgbGF0
ZW5jeSwgYW5kIGhhdmUgdGhlIGtlcm5lbCB1c2UgYSBoaWdoZXINCj4gdmFsdWUgYnkgZGVmYXVs
dCB3aGVuIHRoYXQncyB0aGUgY2FzZS4iIFsxXQ0KPiANCj4gTmVpdGhlciBvZiB3aGljaCB5b3Ug
Y29tbWVudGVkIG9uLiAgSW5zdGVhZCB5b3UgcG9pbnRlZCBtZSB0byBhIGNvbW1lbnQNCj4gdGhh
dCBvbmx5IHBhcnRpYWxseSBkZXNjcmliZWQgd2hhdCB0aGUgbGltaXRhdGlvbnMgd2VyZS4gKEku
ZS4sIGl0DQo+IGRlc2NyaWJlZCB0aGUgInR3byBwYWNrZXRzIG9yIDFtcyIsIGJ1dCBub3QgaG93
IHRoZXkgcmVsYXRlZCwgbm9yIGhvdw0KPiB0aGV5IHJlbGF0ZWQgdG8gdGhlICJtYXggb2YgMiA2
NGsgcGFja2V0cyBvdXRzdGFuZGluZyIgb2YgdGhlIGRlZmF1bHQNCj4gdGNwX2xpbWl0X291dHB1
dF9ieXRlcyBzZXR0aW5nLikNCg0KSVNUTSB0aGF0IHlvdSBhcmUgY2hhbmdpbmcgdGhlIHdyb25n
IGtub2IuDQpZb3UgbmVlZCB0byBjaGFuZ2Ugc29tZXRoaW5nIHRoYXQgYWZmZWN0cyB0aGUgZ2xv
YmFsIGFtb3VudCBvZiBwZW5kaW5nIHR4IGRhdGEsDQpub3QgdGhlIGFtb3VudCB0aGF0IGNhbiBi
ZSBidWZmZXJlZCBieSBhIHNpbmdsZSBjb25uZWN0aW9uLg0KDQpJZiB5b3UgY2hhbmdlIHRjcF9s
aW1pdF9vdXRwdXRfYnl0ZXMgYW5kIHRoZW4gaGF2ZSAxMDAwIGNvbm5lY3Rpb25zIHRyeWluZw0K
dG8gc2VuZCBkYXRhIHlvdSdsbCBzdWZmZXIgJ2J1ZmZlcmJsb2F0Jy4NCg0KSWYgeW91IGNhbGwg
c2tiX29ycGhhbigpIGluIHRoZSB0eCBzZXR1cCBwYXRoIHRoZW4gdGhlIHRvdGFsIG51bWJlciBv
Zg0KYnVmZmVycyBpcyBsaW1pdGVkLCBidXQgYSBzaW5nbGUgY29ubmVjdGlvbiBjYW4gKGFuZCB3
aWxsKSB3aWxsIHRoZSB0eA0KcmluZyBsZWFkaW5nIHRvIGluY29ycmVjdCBSVFQgY2FsY3VsYXRp
b25zIGFuZCBhZGRpdGlvbmFsIGxhdGVuY3kgZm9yDQpvdGhlciBjb25uZWN0aW9ucy4NClRoaXMg
d2lsbCBnaXZlIGhpZ2ggc2luZ2xlIGNvbm5lY3Rpb24gdGhyb3VnaHB1dCBidXQgaXNuJ3QgaWRl
YWwuDQoNCk9uZSBwb3NzaWJpbGl0eSBtaWdodCBiZSB0byBjYWxsIHNrYl9vcnBoYW4oKSB3aGVu
IGVub3VnaCB0aW1lIGhhcw0KZWxhcHNlZCBzaW5jZSB0aGUgcGFja2V0IHdhcyBxdWV1ZWQgZm9y
IHRyYW5zbWl0IHRoYXQgaXQgaXMgdmVyeSBsaWtlbHkNCnRvIGhhdmUgYWN0dWFsbHkgYmVlbiB0
cmFuc21pdHRlZCAtIGV2ZW4gdGhvdWdoICd0cmFuc21pdCBkb25lJyBoYXMNCm5vdCB5ZXQgYmVl
biBzaWduYWxsZWQuDQpOb3QgYXQgYWxsIHN1cmUgaG93IHRoaXMgd291bGQgZml0IGluIHRob3Vn
aC4uLg0KDQoJRGF2aWQNCg0KDQo=
