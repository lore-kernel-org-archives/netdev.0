From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 20/20] i40e: don't allow i40e_vsi_(add|kill)_vlan to
 operate when VID<1
Date: Wed, 7 Dec 2016 21:50:09 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857CD9C6D@ORSMSX115.amr.corp.intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
 <20161207073354.88568-21-jeffrey.t.kirsher@intel.com>
 <8f82cd1d-0118-7b37-1a05-fa7b77d4e75c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:20639 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933093AbcLGVuL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:50:11 -0500
In-Reply-To: <8f82cd1d-0118-7b37-1a05-fa7b77d4e75c@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTZXJnZWkgU2h0eWx5b3YgW21h
aWx0bzpzZXJnZWkuc2h0eWx5b3ZAY29nZW50ZW1iZWRkZWQuY29tXQ0KPiBTZW50OiBXZWRuZXNk
YXksIERlY2VtYmVyIDA3LCAyMDE2IDI6MTEgQU0NCj4gVG86IEtpcnNoZXIsIEplZmZyZXkgVCA8
amVmZnJleS50LmtpcnNoZXJAaW50ZWwuY29tPjsgZGF2ZW1AZGF2ZW1sb2Z0Lm5ldA0KPiBDYzog
S2VsbGVyLCBKYWNvYiBFIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+OyBuZXRkZXZAdmdlci5r
ZXJuZWwub3JnOw0KPiBuaG9ybWFuQHJlZGhhdC5jb207IHNhc3NtYW5uQHJlZGhhdC5jb207IGpv
Z3JlZW5lQHJlZGhhdC5jb207DQo+IGd1cnUuYW5iYWxhZ2FuZUBvcmFjbGUuY29tDQo+IFN1Ympl
Y3Q6IFJlOiBbbmV0LW5leHQgMjAvMjBdIGk0MGU6IGRvbid0IGFsbG93IGk0MGVfdnNpXyhhZGR8
a2lsbClfdmxhbiB0byBvcGVyYXRlDQo+IHdoZW4gVklEPDENCj4gDQo+IEhlbGxvIQ0KPiA+ICsJ
aWYgKCEodmlkID4gMCkgfHwgdnNpLT5pbmZvLnB2aWQpDQo+IA0KPiAgICAgV2h5IG5vdCBqdXN0
ICchdmlkJz8NCg0KTGVmdCBvdmVyIGFydGlmYWN0IG9mIHRoaXMgcHJldmlvdXNseSBiZWluZyBh
IHNpZ25lZCB2YWx1ZS4gV2UgY2FuIGZpeCB0aGlzLg0KDQpUaGFua3MsDQpKYWtlDQoNCj4gPiAt
dm9pZCBpNDBlX3ZzaV9raWxsX3ZsYW4oc3RydWN0IGk0MGVfdnNpICp2c2ksIHMxNiB2aWQpDQo+
ID4gK3ZvaWQgaTQwZV92c2lfa2lsbF92bGFuKHN0cnVjdCBpNDBlX3ZzaSAqdnNpLCB1MTYgdmlk
KQ0KPiA+ICB7DQo+ID4gKwlpZiAoISh2aWQgPiAwKSB8fCB2c2ktPmluZm8ucHZpZCkNCj4gDQo+
ICAgICBMaWtld2lzZS4NCg0KU2FtZSBoZXJlLiBDYW4gZ2V0IHRoaXMgZml4ZWQuDQoNClRoYW5r
cywNCkpha2UNCg0KPiANCj4gPiArCQlyZXR1cm47DQo+ID4gKw0KPiA+ICAJc3Bpbl9sb2NrX2Jo
KCZ2c2ktPm1hY19maWx0ZXJfaGFzaF9sb2NrKTsNCj4gPiAgCWk0MGVfcm1fdmxhbl9hbGxfbWFj
KHZzaSwgdmlkKTsNCj4gPiAgCXNwaW5fdW5sb2NrX2JoKCZ2c2ktPm1hY19maWx0ZXJfaGFzaF9s
b2NrKTsNCj4gDQo+IE1CUiwgU2VyZ2VpDQoNCg==
