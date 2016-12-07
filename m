From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 20/20] i40e: don't allow i40e_vsi_(add|kill)_vlan to
 operate when VID<1
Date: Wed, 7 Dec 2016 22:00:28 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857CD9D41@ORSMSX115.amr.corp.intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
         <20161207073354.88568-21-jeffrey.t.kirsher@intel.com>
         <8f82cd1d-0118-7b37-1a05-fa7b77d4e75c@cogentembedded.com>
         <02874ECE860811409154E81DA85FBB5857CD9C6D@ORSMSX115.amr.corp.intel.com>
 <1481147594.2404.22.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        "guru.anbalagane@oracle.com" <guru.anbalagane@oracle.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:26826 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932777AbcLGWAc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:00:32 -0500
In-Reply-To: <1481147594.2404.22.camel@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogS2lyc2hlciwgSmVmZnJl
eSBUDQo+IFNlbnQ6IFdlZG5lc2RheSwgRGVjZW1iZXIgMDcsIDIwMTYgMTo1MyBQTQ0KPiBUbzog
S2VsbGVyLCBKYWNvYiBFIDxqYWNvYi5lLmtlbGxlckBpbnRlbC5jb20+OyBTZXJnZWkgU2h0eWx5
b3YNCj4gPHNlcmdlaS5zaHR5bHlvdkBjb2dlbnRlbWJlZGRlZC5jb20+OyBkYXZlbUBkYXZlbWxv
ZnQubmV0DQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBuaG9ybWFuQHJlZGhhdC5jb207
IHNhc3NtYW5uQHJlZGhhdC5jb207DQo+IGpvZ3JlZW5lQHJlZGhhdC5jb207IGd1cnUuYW5iYWxh
Z2FuZUBvcmFjbGUuY29tDQo+IFN1YmplY3Q6IFJlOiBbbmV0LW5leHQgMjAvMjBdIGk0MGU6IGRv
bid0IGFsbG93IGk0MGVfdnNpXyhhZGR8a2lsbClfdmxhbiB0byBvcGVyYXRlDQo+IHdoZW4gVklE
PDENCj4gDQo+IE9uIFdlZCwgMjAxNi0xMi0wNyBhdCAxMzo1MCAtMDgwMCwgS2VsbGVyLCBKYWNv
YiBFIHdyb3RlOg0KPiA+ID4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gPiA+IEZyb206
IFNlcmdlaSBTaHR5bHlvdiBbbWFpbHRvOnNlcmdlaS5zaHR5bHlvdkBjb2dlbnRlbWJlZGRlZC5j
b21dDQo+ID4gPiBTZW50OiBXZWRuZXNkYXksIERlY2VtYmVyIDA3LCAyMDE2IDI6MTEgQU0NCj4g
PiA+IFRvOiBLaXJzaGVyLCBKZWZmcmV5IFQgPGplZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT47
IGRhdmVtQGRhdmVtbG9mdC5uDQo+ID4gPiBldA0KPiA+ID4gQ2M6IEtlbGxlciwgSmFjb2IgRSA8
amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPjsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsNCj4gPiA+
IG5ob3JtYW5AcmVkaGF0LmNvbTsgc2Fzc21hbm5AcmVkaGF0LmNvbTsgam9ncmVlbmVAcmVkaGF0
LmNvbTsNCj4gPiA+IGd1cnUuYW5iYWxhZ2FuZUBvcmFjbGUuY29tDQo+ID4gPiBTdWJqZWN0OiBS
ZTogW25ldC1uZXh0IDIwLzIwXSBpNDBlOiBkb24ndCBhbGxvdw0KPiA+ID4gaTQwZV92c2lfKGFk
ZHxraWxsKV92bGFuIHRvIG9wZXJhdGUNCj4gPiA+IHdoZW4gVklEPDENCj4gPiA+DQo+ID4gPiBI
ZWxsbyENCj4gPiA+ID4gK8KgwqDCoGlmICghKHZpZCA+IDApIHx8IHZzaS0+aW5mby5wdmlkKQ0K
PiA+ID4NCj4gPiA+IMKgwqDCoMKgIFdoeSBub3QganVzdCAnIXZpZCc/DQo+ID4NCj4gPiBMZWZ0
IG92ZXIgYXJ0aWZhY3Qgb2YgdGhpcyBwcmV2aW91c2x5IGJlaW5nIGEgc2lnbmVkIHZhbHVlLiBX
ZSBjYW4gZml4DQo+ID4gdGhpcy4NCj4gPg0KPiA+IFRoYW5rcywNCj4gPiBKYWtlDQo+ID4NCj4g
PiA+ID4gLXZvaWQgaTQwZV92c2lfa2lsbF92bGFuKHN0cnVjdCBpNDBlX3ZzaSAqdnNpLCBzMTYg
dmlkKQ0KPiA+ID4gPiArdm9pZCBpNDBlX3ZzaV9raWxsX3ZsYW4oc3RydWN0IGk0MGVfdnNpICp2
c2ksIHUxNiB2aWQpDQo+ID4gPiA+IMKgIHsNCj4gPiA+ID4gK8KgwqDCoGlmICghKHZpZCA+IDAp
IHx8IHZzaS0+aW5mby5wdmlkKQ0KPiA+ID4NCj4gPiA+IMKgwqDCoMKgIExpa2V3aXNlLg0KPiA+
DQo+ID4gU2FtZSBoZXJlLiBDYW4gZ2V0IHRoaXMgZml4ZWQuDQo+IA0KPiBXaGlsZSB5b3UgYXJl
IGZpeGluZyB0aGlzIHVwIGFuZCBzZW5kaW5nIG1lIGEgbmV3IHZlcnNpb24gb2YgdGhpcyBwYXRj
aCwgSQ0KPiB3aWxsIGp1c3QgZHJvcCB0aGlzIGZyb20gdGhlIHNlcmllcyBhbmQgcmUtc2VuZC4N
Cg0KWWVzLCBzaW5jZSBpdCdzIHRoZSBsYXN0IHBhdGNoIHRoYXQncyBmaW5lLg0KDQpUaGFua3Ms
DQpKYWtlDQo=
