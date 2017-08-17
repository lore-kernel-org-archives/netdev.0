From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Thu, 17 Aug 2017 08:10:05 +0000
Message-ID: <KL1P15301MB0008240E2EA69E54BEAC9E9EBF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <E1772BF8-8A8D-4768-AA8C-67EE8FE21D10@vmware.com>
 <KL1P15301MB00088FBEB371152A913981BABF820@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: 'Michal Kubecek' <mkubecek@suse.cz>, "'joe@perches.com'" <joe@perches.com>,
 "'olaf@aepfle.de'" <olaf@aepfle.de>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 "'jasowang@redhat.com'" <jasowang@redhat.com>,
 "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, 'Dave Scott' <dave.scott@docker.com>,
 "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
 "'apw@canonical.com'" <apw@canonical.com>,
 'Rolf Neugebauer' <rolf.neugebauer@docker.com>,
 'Stefan Hajnoczi' <stefanha@redhat.com>,
 "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>, 'Marcelo
 Cerri' <marcelo.cerri@canonical.com>,
 "'devel@linuxdriverproject.org'" <devel@linuxdriverproject.org>,
 'Asias He' <asias@redhat.com>, 'Vitaly
 Kuznetsov' <vkuznets@redhat.com>, 'George Zhang' <georgezhang@vmware.com>,
 'Dan Carpenter' <dan.carpenter@oracle.com>
To: "'Jorgen S. Hansen'" <jhansen@vmware.com>, "'davem@davemloft.net'"
 <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <KL1P15301MB00088FBEB371152A913981BABF820@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBEZXh1YW4gQ3VpDQo+IFNlbnQ6IFdlZG5lc2RheSwgQXVndXN0IDE2LCAyMDE3IDE1
OjM0DQo+ID4gRnJvbTogSm9yZ2VuIFMuIEhhbnNlbiBbbWFpbHRvOmpoYW5zZW5Adm13YXJlLmNv
bV0NCj4gPiA+IFdpdGhvdXQgdGhlIHBhdGNoLCB2bXdfdnNvY2tfdm1jaV90cmFuc3BvcnQua28g
YW5kIHZtd192bWNpLmtvIGNhbg0KPiA+ID4gYXV0b21hdGljYWxseSBsb2FkIHdoZW4gYW4gYXBw
bGljYXRpb24gY3JlYXRlcyBhbiBBRl9WU09DSyBzb2NrZXQuDQo+ID4gPg0KPiA+ID4gVGhpcyBp
cyB0aGUgZXhwZWN0ZWQgZ29vZCBiZWhhdmlvciBvbiBWTXdhcmUgaHlwZXJ2aXNvciwgYnV0IGFz
IHdlDQo+ID4gPiBhcmUgZ29pbmcgdG8gYWRkIGh2X3NvY2sua28gKGkuZS4gSHlwZXItViB0cmFu
c3BvcnQgZm9yIEFGX1ZTT0NLKSwgd2UNCj4gPiA+IHNob3VsZCBtYWtlIHN1cmUgdm13X3Zzb2Nr
X3ZtY2lfdHJhbnNwb3J0LmtvIGRvZXNuJ3QgbG9hZCBvbiBIeXBlci0NCj4gViwNCj4gPiA+IG90
aGVyd2lzZSB0aGVyZSBpcyBhIC1FQlVTWSBjb25mbGljdCB3aGVuIGJvdGgNCj4gdm13X3Zzb2Nr
X3ZtY2lfdHJhbnNwb3J0LmtvDQo+ID4gPiBhbmQgaHZfc29jay5rbyB0cnkgdG8gY2FsbCB2c29j
a19jb3JlX2luaXQoKSBvbiBIeXBlci1WLg0KPiA+DQo+ID4gVGhlIFZNQ0kgZHJpdmVyICh2bXdf
dm1jaS5rbykgaXMgdXNlZCBib3RoIGJ5IHRoZSBWTXdhcmUgZ3Vlc3Qgc3VwcG9ydA0KPiA+IChW
TXdhcmUgVG9vbHMgcHJpbWFyaWx5KSBhbmQgYnkgb3VyIFdvcmtzdGF0aW9uIHByb2R1Y3QuIEFs
d2F5cw0KPiBkaXNhYmxpbmcgdGhlDQo+ID4gVk1DSSBkcml2ZXIgb24gSHlwZXItViBtZWFucyB0
aGF0IHVzZXIgd29u4oCZdCBiZSBhYmxlIHRvIHJ1biBXb3Jrc3RhdGlvbg0KPiA+IG5lc3RlZCBp
biBMaW51eCBWTXMgb24gSHlwZXItVi4gU2luY2UgdGhlIFZNQ0kgZHJpdmVyIGl0c2VsZiBpc27i
gJl0IHRoZQ0KPiBwcm9ibGVtDQo+ID4gaGVyZSwgbWF5YmUgd2UgY291bGQgbW92ZSB0aGUgY2hl
Y2sgdG8gdm13X3Zzb2NrX3ZtY2lfdHJhbnNwb3J0LmtvPw0KPiA+IElkZWFsbHksIHRoZXJlIHNo
b3VsZCBiZSBzb21lIHdheSBmb3IgYSB1c2VyIHRvIGhhdmUgYWNjZXNzIHRvIGJvdGgNCj4gcHJv
dG9jb2xzLA0KPiA+IGJ1dCBmb3Igbm93IGRpc2FibGluZyB0aGUgVk1DSSBzb2NrZXQgdHJhbnNw
b3J0IGZvciBIeXBlci1WIChwb3NzaWJseSB3aXRoDQo+IGENCj4gPiBtb2R1bGUgb3B0aW9uIHRv
IHNraXAgdGhhdCBjaGVjayBhbmQgYWx3YXlzIGxvYWQgaXQpIGJ1dCBsZWF2aW5nIHRoZSBWTUNJ
DQo+IGRyaXZlcg0KPiA+IGZ1bmN0aW9uYWwgd291bGQgYmUgYmV0dGVyLA0KPiA+DQo+ID4gSm9y
Z2VuDQo+IA0KPiBUaGFuayB5b3UgZm9yIGV4cGxhaW5pbmcgdGhlIGJhY2tncm91bmQhDQo+IFRo
ZW4gSSdsbCBtYWtlIGEgbmV3IHBhdGNoLCBmb2xsb3dpbmcgeW91ciBzdWdnZXN0aW9uLg0KPiAN
Cj4gLS0gRGV4dWFuDQoNCkhpIEpvcmdlbiwgRGF2aWQsDQoNCkp1c3Qgbm93IEkgcG9zdGVkIGEg
bmV3IHBhdGNoDQogIltQQVRDSF0gdnNvY2s6IG9ubHkgbG9hZCB2bWNpIHRyYW5zcG9ydCBvbiBW
TXdhcmUgaHlwZXJ2aXNvciBieSBkZWZhdWx0Ig0KdG8gcmVwbGFjZSB0aGlzIHBhdGNoLg0KDQpA
Sm9yZ2VuOiANCkZXSVcsIHdpdGggdGhlIG5ldyBwYXRjaCwgd2hlbiBJIGNyZWF0ZSBhbiBBRl9W
U09DSyBzb2NrZXRzIG9uIEh5cGVyLVYsDQp2bXdfdm1jaS5rbyBpcyBhbHNvIGF1dG9tYXRpY2Fs
bHkgbG9hZGVkIGFuZCAzIGxpbmVzIG9mIGtlcm5lbCBtZXNzYWdlcyBhcmUNCnByaW50ZWQsIGJ1
dCBJIHRoaW5rIEknbSBPSyB3aXRoIHRoaXMsIHNpbmNlIGl0J3MgaGFybWxlc3MuDQoNCi0tIERl
eHVhbg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KZGV2
ZWwgbWFpbGluZyBsaXN0CmRldmVsQGxpbnV4ZHJpdmVycHJvamVjdC5vcmcKaHR0cDovL2RyaXZl
cmRldi5saW51eGRyaXZlcnByb2plY3Qub3JnL21haWxtYW4vbGlzdGluZm8vZHJpdmVyZGV2LWRl
dmVsCg==
