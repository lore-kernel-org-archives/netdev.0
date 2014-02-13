From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: Re: [net-next 2/5] ixgbe: implement SIOCGHWTSTAMP ioctl
Date: Thu, 13 Feb 2014 21:46:22 +0000
Message-ID: <1392327982.30559.1.camel@jekeller-desk1.amr.corp.intel.com>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
	 <1392278450-27062-3-git-send-email-aaron.f.brown@intel.com>
	 <1392321789.15615.49.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Brown, Aaron F" <aaron.f.brown@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:5522 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbaBMVq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 16:46:27 -0500
In-Reply-To: <1392321789.15615.49.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Content-ID: <228C027284CA584085925F3F1B2725AD@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE0LTAyLTEzIGF0IDIwOjAzICswMDAwLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0K
PiBPbiBUaHUsIDIwMTQtMDItMTMgYXQgMDA6MDAgLTA4MDAsIEFhcm9uIEJyb3duIHdyb3RlOg0K
PiBbLi4uXQ0KPiA+ICtpbnQgaXhnYmVfcHRwX3NldF90c19jb25maWcoc3RydWN0IGl4Z2JlX2Fk
YXB0ZXIgKmFkYXB0ZXIsIHN0cnVjdCBpZnJlcSAqaWZyKQ0KPiA+ICB7DQo+ID4gIAlzdHJ1Y3Qg
aXhnYmVfaHcgKmh3ID0gJmFkYXB0ZXItPmh3Ow0KPiA+IC0Jc3RydWN0IGh3dHN0YW1wX2NvbmZp
ZyBjb25maWc7DQo+ID4gKwlzdHJ1Y3QgaHd0c3RhbXBfY29uZmlnICpjb25maWcgPSAmYWRhcHRl
ci0+dHN0YW1wX2NvbmZpZzsNCj4gPiAgCXUzMiB0c3luY190eF9jdGwgPSBJWEdCRV9UU1lOQ1RY
Q1RMX0VOQUJMRUQ7DQo+ID4gIAl1MzIgdHN5bmNfcnhfY3RsID0gSVhHQkVfVFNZTkNSWENUTF9F
TkFCTEVEOw0KPiA+ICAJdTMyIHRzeW5jX3J4X210cmwgPSBQVFBfRVZfUE9SVCA8PCAxNjsNCj4g
PiAgCWJvb2wgaXNfbDIgPSBmYWxzZTsNCj4gPiAgCXUzMiByZWd2YWw7DQo+ID4gIA0KPiA+IC0J
aWYgKGNvcHlfZnJvbV91c2VyKCZjb25maWcsIGlmci0+aWZyX2RhdGEsIHNpemVvZihjb25maWcp
KSkNCj4gPiArCWlmIChjb3B5X2Zyb21fdXNlcihjb25maWcsIGlmci0+aWZyX2RhdGEsIHNpemVv
ZigqY29uZmlnKSkpDQo+ID4gIAkJcmV0dXJuIC1FRkFVTFQ7DQo+IFsuLi5dDQo+IA0KPiBUaGlz
IGlzIHdyb25nLiAgWW91IG92ZXJ3cml0ZSB0aGUgY3VycmVudCBjb25maWcgYmVmb3JlIHZhbGlk
YXRpbmcgaXQuDQo+IA0KPiBCZW4uDQo+IA0KDQpPb3BzLiBUaGFua3MgZm9yIHRoZSBjYXRjaC4g
SSdsbCByZXNwaW4gdGhpcy4NCg0KUmVnYXJkcywNCkpha2UNCg==
