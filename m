From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Thu, 19 Oct 2017 18:34:47 +0000
Message-ID: <AM0PR0502MB36837A6D2DFF8FDE012A7D91BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
 <AM0PR0502MB36835F863A3E05376F3562B1BF420@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <CA+Jmh7H+u1-1Ot2TxLXEHk2HW=p+yeT02cexNPC1nW5V_gMVgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "michael.chan@broadcom.com" <michael.chan@broadcom.com>,
        "linville@tuxdriver.com" <linville@tuxdriver.com>,
        "gospo@broadcom.com" <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40088.outbound.protection.outlook.com ([40.107.4.88]:16480
        "EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754344AbdJSSev (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Oct 2017 14:34:51 -0400
In-Reply-To: <CA+Jmh7H+u1-1Ot2TxLXEHk2HW=p+yeT02cexNPC1nW5V_gMVgQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPbiBUaHUsIE9jdCAxOSwgMjAxNyBhdCAyOjA3IEFNLCBZdXZhbCBNaW50eiA8eXV2YWxtQG1l
bGxhbm94LmNvbT4NCj4gd3JvdGU6DQo+ID4+ICtlbnVtIGRldmxpbmtfYXV0b25lZ19wcm90b2Nv
bCB7DQo+ID4+ICsgICAgIERFVkxJTktfQVVUT05FR19QUk9UT0NPTF9JRUVFODAyM0JZX0JBTSwN
Cj4gPj4gKyAgICAgREVWTElOS19BVVRPTkVHX1BST1RPQ09MX0lFRUU4MDIzQllfQ09OU09SVElV
TSwNCj4gPj4gKyAgICAgREVWTElOS19BVVRPTkVHX1BST1RPQ09MX0lFRUU4MDIzQlksDQo+ID4+
ICsgICAgIERFVkxJTktfQVVUT05FR19QUk9UT0NPTF9CQU0sICAgICAgICAgICAvKiBCcm9hZGNv
bQ0KPiA+PiBBdXRvbmVnIE1vZGUgKi8NCj4gPj4gKyAgICAgREVWTElOS19BVVRPTkVHX1BST1RP
Q09MX0NPTlNPUlRJVU0sICAgIC8qDQo+ID4+IENvbnNvcnRpdW0gQXV0b25lZyBNb2RlICovDQo+
ID4+ICt9Ow0KPiA+DQo+ID4gV291bGRuJ3QgYWRkaW5nIEJBTSBhcyBhICdnZW5lcmljJyBtb2Rl
IG9mIG9wZXJhdGlvbiBiZSBsaWtlIGFkZGluZw0KPiA+IG5vbi1jb25zb3J0aXVtIHNwZWVkcyB0
byBldGh0b29sIEFQST8NCj4gPiBbSSBwcm9mZXNzIGlnbm9yYW5jZSBpbiB0aGlzIGFyZWE7IEZv
ciBhbGwgSSBrbm93IGl0IGNhbiBiZSBhIHdpZGVseSBhY2NlcHRlZA0KPiA+IGluZHVzdHJ5IHN0
YW5kYXJkXQ0KPiA+DQo+IA0KPiBZdXZhbCwgSSdtIGdsYWQgdG8gZ2V0IGlucHV0IGZyb20gb3Ro
ZXIgTklDIHZlbmRvcnMuICANCk90aGVyIHN3aXRjaCB2ZW5kb3JzIDspDQoNCj5UaGUgaGlnaC1s
ZXZlbCBnb2FsIG9mIHRoaXMgZWZmb3J0IGlzIHRvIGFsbG93IHVzZXJzIG9mIHZhcmlvdXMgdmVu
ZG9ycycgTklDcyB0byBiZQ0KPiBhYmxlIHRvIGNvbmZpZ3VyZSB0aGVzZSB0eXBlcyBvZiBOVlJB
TS9wZXJtYW5lbnQvZGVmYXVsdCBzZXR0aW5ncw0KPiB1c2luZyBhbiBpbmJveCB0b29sLCByYXRo
ZXIgdGhhbiB0aGUgY29sbGVjdGlvbiBvZiB2ZW5kb3Itc3BlY2lmaWMNCj4gdG9vbHMgdGhhdCBp
cyB0aGUgc3RhdHVzIHF1by4NCj4gDQo+IEluIG9yZGVyIHRvIHByb3ZpZGUgdGhhdCBmdW5jdGlv
bmFsaXR5LCBpdCBzZWVtcyBsaWtlIHRoZQ0KPiB2ZW5kb3Itc3BlY2lmaWMgcGFyYW1ldGVycyBh
bmQgYWxzbyB0aGUgdmVuZG9yLXNwZWNpZmljIHNldHRpbmdzIG9mDQo+IGNvbW1vbiBwYXJhbWV0
ZXJzIGJvdGggbmVlZCB0byBiZSBzdXBwb3J0ZWQgaW4gdGhpcyBtYW5uZXIuDQo+IA0KPiBJZGVh
bGx5IHRoZXJlIHdpbGwgYmUgbXVjaCBvdmVybGFwIGluIGJvdGggdGhlIHNldCBvZiBwYXJhbWV0
ZXJzDQo+IGF2YWlsYWJsZSBhcyB3ZWxsIGFzIHRoZSBvcHRpb25zIGZvciBlYWNoIHBhcmFtZXRl
ciwgYnV0IGluIHRoZSByZWFsDQo+IHdvcmxkLCB0aGVyZSB3aWxsIGFsd2F5cyBiZSBkaWZmZXJl
bmNlcyBiZXR3ZWVuIHZlbmRvcnMgYW5kIGV2ZW4NCj4gYmV0d2VlbiBkaWZmZXJlbnQgZGV2aWNl
cyAoZHJpdmVycykgZnJvbSB0aGUgc2FtZSB2ZW5kb3IuICBEZXNwaXRlDQo+IHRoYXQgcmVhbGl0
eSwgSSB0aGluayB0aGVyZSBpcyBzdGlsbCBncmVhdCBiZW5lZml0IGluIGhhdmluZyBhIGNvbW1v
bg0KPiBpbmJveCB0b29sIHRoYXQgdXNlcnMgY2FuIHVzZSBmb3IgZGV2aWNlIGNvbmZpZ3VyYXRp
b24gb2YgdGhpcyB0eXBlLg0KPiBJdCBqdXN0IG1lYW5zIHRoYXQgbm90IGFsbCBkcml2ZXJzIHdp
bGwgc3VwcG9ydCBhbGwgcGFyYW1ldGVycywgbm9yDQo+IGFsbCBvcHRpb25zIGZvciBlYWNoIHBh
cmFtZXRlciB0aGF0IHRoZXkgZG8gc3VwcG9ydC4NCg0KSSBkb24ndCBvYmplY3QgdGhlIGVuZC1n
b2FsOyBJIHRoaW5rIG15IGhlc2l0YXRpb24gaXMgZHVlIHRvIHRoZSBzYW1lDQplbnVtIGNvbnRh
aW5pbmcgYm90aCBnZW5lcmljIGFuZCB2ZW5kb3Itc3BlY2lmaWMgdmFsdWVzIG1peGVkDQp0b2dl
dGhlci4gSSBmZWVsIGxpa2Ugd2UgbmVlZCBzb21lIGNsZWFyIGRpc3RpbmN0aW9uIGJldHdlZW4g
dGhlIHR3by4NCg0KPiANCj4gVGhhbmtzLA0KPiBTdGV2ZQ0K
