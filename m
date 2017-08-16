From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Wed, 16 Aug 2017 22:33:43 +0000
Message-ID: <KL1P15301MB00088FBEB371152A913981BABF820@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <E1772BF8-8A8D-4768-AA8C-67EE8FE21D10@vmware.com>
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
        Stefan Hajnoczi <stefanha@redhat.com>,
        "Vitaly Kuznetsov" <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        "Marcelo Cerri" <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E1772BF8-8A8D-4768-AA8C-67EE8FE21D10@vmware.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBKb3JnZW4gUy4gSGFuc2VuIFttYWlsdG86amhhbnNlbkB2bXdhcmUuY29tXQ0KPiA+
IFdpdGhvdXQgdGhlIHBhdGNoLCB2bXdfdnNvY2tfdm1jaV90cmFuc3BvcnQua28gYW5kIHZtd192
bWNpLmtvIGNhbg0KPiA+IGF1dG9tYXRpY2FsbHkgbG9hZCB3aGVuIGFuIGFwcGxpY2F0aW9uIGNy
ZWF0ZXMgYW4gQUZfVlNPQ0sgc29ja2V0Lg0KPiA+DQo+ID4gVGhpcyBpcyB0aGUgZXhwZWN0ZWQg
Z29vZCBiZWhhdmlvciBvbiBWTXdhcmUgaHlwZXJ2aXNvciwgYnV0IGFzIHdlDQo+ID4gYXJlIGdv
aW5nIHRvIGFkZCBodl9zb2NrLmtvIChpLmUuIEh5cGVyLVYgdHJhbnNwb3J0IGZvciBBRl9WU09D
SyksIHdlDQo+ID4gc2hvdWxkIG1ha2Ugc3VyZSB2bXdfdnNvY2tfdm1jaV90cmFuc3BvcnQua28g
ZG9lc24ndCBsb2FkIG9uIEh5cGVyLVYsDQo+ID4gb3RoZXJ3aXNlIHRoZXJlIGlzIGEgLUVCVVNZ
IGNvbmZsaWN0IHdoZW4gYm90aCB2bXdfdnNvY2tfdm1jaV90cmFuc3BvcnQua28NCj4gPiBhbmQg
aHZfc29jay5rbyB0cnkgdG8gY2FsbCB2c29ja19jb3JlX2luaXQoKSBvbiBIeXBlci1WLg0KPiAN
Cj4gVGhlIFZNQ0kgZHJpdmVyICh2bXdfdm1jaS5rbykgaXMgdXNlZCBib3RoIGJ5IHRoZSBWTXdh
cmUgZ3Vlc3Qgc3VwcG9ydA0KPiAoVk13YXJlIFRvb2xzIHByaW1hcmlseSkgYW5kIGJ5IG91ciBX
b3Jrc3RhdGlvbiBwcm9kdWN0LiBBbHdheXMgZGlzYWJsaW5nIHRoZQ0KPiBWTUNJIGRyaXZlciBv
biBIeXBlci1WIG1lYW5zIHRoYXQgdXNlciB3b27igJl0IGJlIGFibGUgdG8gcnVuIFdvcmtzdGF0
aW9uDQo+IG5lc3RlZCBpbiBMaW51eCBWTXMgb24gSHlwZXItVi4gU2luY2UgdGhlIFZNQ0kgZHJp
dmVyIGl0c2VsZiBpc27igJl0IHRoZSBwcm9ibGVtDQo+IGhlcmUsIG1heWJlIHdlIGNvdWxkIG1v
dmUgdGhlIGNoZWNrIHRvIHZtd192c29ja192bWNpX3RyYW5zcG9ydC5rbz8NCj4gSWRlYWxseSwg
dGhlcmUgc2hvdWxkIGJlIHNvbWUgd2F5IGZvciBhIHVzZXIgdG8gaGF2ZSBhY2Nlc3MgdG8gYm90
aCBwcm90b2NvbHMsDQo+IGJ1dCBmb3Igbm93IGRpc2FibGluZyB0aGUgVk1DSSBzb2NrZXQgdHJh
bnNwb3J0IGZvciBIeXBlci1WIChwb3NzaWJseSB3aXRoIGENCj4gbW9kdWxlIG9wdGlvbiB0byBz
a2lwIHRoYXQgY2hlY2sgYW5kIGFsd2F5cyBsb2FkIGl0KSBidXQgbGVhdmluZyB0aGUgVk1DSSBk
cml2ZXINCj4gZnVuY3Rpb25hbCB3b3VsZCBiZSBiZXR0ZXIsDQo+IA0KPiBKb3JnZW4NCg0KVGhh
bmsgeW91IGZvciBleHBsYWluaW5nIHRoZSBiYWNrZ3JvdW5kIQ0KVGhlbiBJJ2xsIG1ha2UgYSBu
ZXcgcGF0Y2gsIGZvbGxvd2luZyB5b3VyIHN1Z2dlc3Rpb24uDQoNCi0tIERleHVhbg0K
