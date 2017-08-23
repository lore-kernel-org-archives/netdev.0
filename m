From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Wed, 23 Aug 2017 04:21:21 +0000
Message-ID: <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822095437.GB16799@stefanha-x1.localdomain>
 <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>, Asias He <asias@redhat.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        "Cathy Avery" <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "Rolf Neugebauer" <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
To: "Jorgen S. Hansen" <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pu1apc01on0119.outbound.protection.outlook.com ([104.47.126.119]:45293
        "EHLO APC01-PU1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751237AbdHWEVo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 00:21:44 -0400
In-Reply-To: <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBKb3JnZW4gUy4gSGFuc2VuIFttYWlsdG86amhhbnNlbkB2bXdhcmUuY29tXQ0KPiA+
IE9uIEF1ZyAyMiwgMjAxNywgYXQgMTE6NTQgQU0sIFN0ZWZhbiBIYWpub2N6aSA8c3RlZmFuaGFA
cmVkaGF0LmNvbT4NCj4gd3JvdGU6DQo+ID4gLi4uDQo+ID4gV2UgKmNhbiogYnkgbG9va2luZyBh
dCB0aGUgZGVzdGluYXRpb24gQ0lELiAgUGxlYXNlIHRha2UgYSBsb29rIGF0DQo+ID4gZHJpdmVy
cy9taXNjL3Ztd192bWNpL3ZtY2lfcm91dGUuYzp2bWNpX3JvdXRlKCkgdG8gc2VlIGhvdyBWTUNJ
DQo+IGhhbmRsZXMNCj4gPiBuZXN0ZWQgdmlydC4NCj4gPg0KPiA+IEl0IGJvaWxzIGRvd24gdG8g
c29tZXRoaW5nIGxpa2UgdGhpczoNCj4gPg0KPiA+ICBzdGF0aWMgaW50IHZzb2NrX3N0cmVhbV9j
b25uZWN0KHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBzb2NrYWRkciAqYWRkciwNCj4gPiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBpbnQgYWRkcl9sZW4sIGludCBmbGFncykN
Cj4gPiAgew0KPiA+ICAgICAgLi4uDQo+ID4gICAgICBpZiAocmVtb3RlX2FkZHIuc3ZtX2NpZCA9
PSBWTUFERFJfQ0lEX0hPU1QpDQo+ID4gICAgICAgICAgdHJhbnNwb3J0ID0gaG9zdF90cmFuc3Bv
cnQ7DQo+ID4gICAgICBlbHNlDQo+ID4gICAgICAgICAgdHJhbnNwb3J0ID0gZ3Vlc3RfdHJhbnNw
b3J0Ow0KPiA+DQo+ID4gSXQncyBlYXN5IGZvciBjb25uZWN0KDIpIGJ1dCBKb3JnZW4gbWVudGlv
bmVkIGl0J3MgaGFyZGVyIGZvciBsaXN0ZW4oMikNCj4gPiBiZWNhdXNlIHRoZSBzb2NrZXQgd291
bGQgbmVlZCB0byBsaXN0ZW4gb24gYm90aCB0cmFuc3BvcnRzLiAgV2UgZGVmaW5lDQo+ID4gdHdv
IG5ldyBjb25zdGFudHMgVk1BRERSX0NJRF9MSVNURU5fRlJPTV9HVUVTVCBhbmQNCj4gPiBWTUFE
RFJfQ0lEX0xJU1RFTl9GUk9NX0hPU1QgZm9yIGJpbmQoMikgc28gdGhhdCBhcHBsaWNhdGlvbnMg
Y2FuDQo+IGRlY2lkZQ0KPiA+IHdoaWNoIHNpZGUgdG8gbGlzdGVuIG9uLg0KPiANCj4gSWYgYSBz
b2NrZXQgaXMgYm91bmQgdG8gVk1BRERSX0NJRF9IT1NULCB3ZSB3b3VsZCBjb25zaWRlciB0aGF0
IHNvY2tldCBhcw0KPiBib3VuZCB0byB0aGUgaG9zdCBzaWRlIHRyYW5zcG9ydCwgc28gdGhhdCB3
b3VsZCBiZSB0aGUgc2FtZSBhcw0KPiBWTUFERFJfQ0lEX0xJU1RFTl9GUk9NX0dVRVNULiBGb3Ig
dGhlIGd1ZXN0LCB3ZSBoYXZlDQo+IElPQ1RMX1ZNX1NPQ0tFVFNfR0VUX0xPQ0FMX0NJRCwgc28g
dGhhdCBjb3VsZCBiZSB1c2VkIHRvIGdldCBhbmQgYmluZA0KPiBhIHNvY2tldCB0byB0aGUgZ3Vl
c3QgdHJhbnNwb3J0IChWTUNJIHdpbGwgYWx3YXlzIHJldHVybiB0aGUgZ3Vlc3QgQ0lEIGFzIHRo
ZQ0KPiBsb2NhbCBvbmUsIGlmIHRoZSBWTUNJIGRyaXZlciBpcyB1c2VkIGluIGEgZ3Vlc3QsIGFu
ZCBpdCBsb29rcyBsaWtlIHZpcnRpbyB3aWxsIGRvDQo+IHRoZSBzYW1lKS4gV2UgY291bGQgdHJl
YXQgVk1BRERSX0NJRF9BTlkgYXMgYWx3YXlzIGJlaW5nIHRoZSBndWVzdA0KPiB0cmFuc3BvcnQs
IHNpbmNlIHRoYXQgaXMgdGhlIHVzZSBjYXNlIHdoZXJlIHlvdSBkb27igJl0IGtub3cgdXBmcm9u
dCB3aGF0DQo+IHlvdXIgQ0lEIGlzLCBpZiB3ZSBkb27igJl0IHdhbnQgdG8gbGlzdGVuIG9uIGFs
bCB0cmFuc3BvcnRzLiBTbyB3ZSB3b3VsZCB1c2UgdGhlDQo+IGhvc3QgdHJhbnNwb3J0LCBpZiBh
IHNvY2tldCBpcyBib3VuZCB0byBWTUFERFJfQ0lEX0hPU1QsIG9yIGlmIHRoZXJlIGlzIG5vDQo+
IGd1ZXN0IHRyYW5zcG9ydCwgYW5kIGluIGFsbCBvdGhlciBjYXNlcyB1c2UgdGhlIGd1ZXN0IHRy
YW5zcG9ydC4gSG93ZXZlciwNCj4gaGF2aW5nIGEgY291cGxlIG9mIHN5bWJvbGljIG5hbWVzIGxp
a2UgeW91IHN1Z2dlc3QgY2VydGFpbmx5IG1ha2VzIGl0IG1vcmUNCj4gb2J2aW91cywgYW5kIGNv
dWxkIGJlIHVzZWQgaW4gY29tYmluYXRpb24gd2l0aCB0aGlzLiBJdCB3b3VsZCBiZSBhIHBsdXMg
aWYNCj4gZXhpc3RpbmcgYXBwbGljYXRpb25zIHdvdWxkIGZ1bmN0aW9uIGFzIGludGVuZGVkIGlu
IG1vc3QgY2FzZXMuDQo+IA0KPiA+ICAgT3IgdGhlIGxpc3RlbiBzb2NrZXQgY291bGQgc2ltcGx5
IGxpc3RlbiB0bw0KPiA+IGJvdGggc2lkZXMuDQo+IA0KPiBUaGUgb25seSBwcm9ibGVtIGhlcmUg
d291bGQgYmUgdGhlIHBvdGVudGlhbCBmb3IgYSBndWVzdCBhbmQgYSBob3N0IGFwcCB0bw0KPiBo
YXZlIGEgY29uZmxpY3Qgd3J0IHBvcnQgbnVtYmVycywgZXZlbiB0aG91Z2ggdGhleSB3b3VsZCBi
ZSBhYmxlIHRvDQo+IG9wZXJhdGUgZmluZSwgaWYgcmVzdHJpY3RlZCB0byB0aGVpciBhcHByb3By
aWF0ZSB0cmFuc3BvcnQuDQo+IA0KPiBUaGFua3MsDQo+IEpvcmdlbg0KDQpIaSBKb3JnZW4sIFN0
ZWZhbiwNClRoYW5rIHlvdSBmb3IgdGhlIGRldGFpbGVkIGFuYWx5c2lzIQ0KWW91IGhhdmUgYSBt
dWNoIGJldHRlciB1bmRlcnN0YW5kaW5nIHRoYW4gbWUgYWJvdXQgdGhlIGNvbXBsZXgNCnNjZW5h
cmlvcy4gQ2FuIHlvdSBwbGVhc2Ugd29yayBvdXQgYSBwYXRjaD8gOi0pDQoNCklNTyBMaW51eCBk
cml2ZXIgb2YgSHlwZXItViBzb2NrZXRzIGlzIHRoZSBzaW1wbGVzdCBjYXNlLCBhcyB3ZSBvbmx5
IGhhdmUNCnRoZSAidG8gaG9zdCIgb3B0aW9uICh0aGUgaG9zdCBzaWRlIGRyaXZlciBvZiBIeXBl
ci1WIHNvY2tldHMgcnVucyBvbiANCldpbmRvd3Mga2VybmVsIGFuZCBJIGRvbid0IHRoaW5rIHRo
ZSBvdGhlciBoeXBlcnZpc29ycyBlbXVsYXRlDQp0aGUgZnVsbCBIeXBlci1WIFZNQnVzIDQuMCwg
d2hpY2ggaXMgcmVxdWlyZWQgdG8gc3VwcG9ydCBIeXBlci1WIHNvY2tldHMpLg0KDQotLSBEZXh1
YW4NCg0K
