From: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Subject: RE: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 08:44:01 +0000
Message-ID: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com>
 <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCB944.8090709@nod.at>
 <DC7803B42427924284F2D5252E076A3B4476A363@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCCCAD.7080906@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	Thomas Shao <huishao@microsoft.com>,
	Dexuan Cui <decui@microsoft.com>
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53CCCCAD.7080906@nod.at>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBSaWNoYXJkIFdlaW5iZXJnZXIgW21haWx0bzpyaWNoYXJkQG5vZC5hdF0NCj4gU2Vu
dDogTW9uZGF5LCBKdWx5IDIxLCAyMDE0IDQ6MTggUE0NCj4gDQo+IFl1ZSwNCj4gDQo+IEFtIDIx
LjA3LjIwMTQgMTA6MDUsIHNjaHJpZWIgWXVlIFpoYW5nIChPU1RDIERFVik6DQo+ID4gVGhlIHBy
b2JsZW0gb2Ygc3lzdGVtZCBpbXBsZW1lbnRhdGlvbiBpcyB0aGF0IGluIGRpZmZlcmVudCBkaXN0
cm9zLCB0aGUgd2F5cyANCj4gPiB0byByZXN0YXJ0IHNlcnZpY2UgYXJlIGRpZmZlcmVudC4gUHJv
cGFnYXRpbmcgdGhlIGV2ZW50IHRvIHVzZXJzcGFjZSBhbHNvIGRvZXNuJ3QgDQo+ID4gaGVscCBm
b3IgdGhpcyBpc3N1ZS4NCj4gDQo+IFRoaXMgd2F5IGVhY2ggZGlzdHJvIGNhbiBwcm92aWRlIHRo
ZWlyIG93biByZXN0YXJ0IHNjcmlwdC4NCj4gU2FtZSBhcyBldmVyeSBkaXN0cm8gaGFzIGN1c3Rv
bSBzdGFydCBzY3JpcHRzLCBldGMuLi4NCj4gDQo+ID4gVGhlIGFkdmFudGFnZSBvZiBjdXJyZW50
IHNvbHV0aW9uIGlzIHRoYXQgaXQgc2ltdWxhdGVzIGEgY2FibGUgcGx1Z2dpbmcgDQo+ID4gaW4v
b3V0IGV2ZW50LiBJTUhPLCBpbiBhbGwgdGhlIGRpc3Ryb3MsIHRoaXMgc2ltdWxhdGVkIGV2ZW50
IGhhcyBhbHJlYWR5IGJlZW4gd2VsbCANCj4gPiBoYW5kbGVkLiBJdCBpcyBhIGR1cCBlZmZlY3Qg
dG8gaW1wbGVtZW50IG5ldyBob29rcy4NCj4gDQo+IElmZiB0aGUgY3VycmVudCBzb2x1dGlvbiB3
b3JrcyBmb3IgX2FsbF8gbmV0d29ya2luZyBpbXBsZW1lbnRhdGlvbnMuDQo+IA0KPiBUaGFua3Ms
DQo+IC8vcmljaGFyZA0KDQpIaSwgUmljaGFyZA0KDQpJTUhPLCBhbGwgbmV0d29ya2luZyBpbXBs
ZW1lbnRhdGlvbnMgc2hvdWxkIGhhbmRsZSB0aGUgY2FibGUgb2ZmbGluZSBldmVudC4gQ29uc2lk
ZXINCnRoaXMgc2l0dWF0aW9uLiBJIHVucGx1Z2dlZCB0aGUgbmV0d29yayBjYWJsZSBhbmQgY29u
bmVjdCBpdCB0byBhIG5ldyBuZXR3b3JrIHN3aXRjaA0KYWZ0ZXIgMTAgc2Vjb25kcy4gSWYgdGhl
IERIQ1AgcmVuZXcgaXMgbm90IHRyaWdnZXJlZCwgdGhlIG5ldHdvcmsgd2lsbCBicmVhay4gSSB0
aGluayBpbiANCm5vcm1hbCBjYXNlcywgaXQgc2hvdWxkIGFscmVhZHkgYmVlbiBoYW5kbGVkIHBy
b3Blcmx5LiBVbmxlc3MgdGhlcmUgaXMgYSBzdHJvbmcgDQpqdXN0aWZpY2F0aW9uIGZvciBub3Qg
ZG9pbmcgdGhpcy4gSW4gdGhhdCBjYXNlLCB3ZSBzaG91bGRuJ3QgcmVuZXcgREhDUCBhbnl3YXku
DQoNClRoYW5rcw0KLS0tLQ0KWXVlDQo=
