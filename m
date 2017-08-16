From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Wed, 16 Aug 2017 19:44:47 +0000
Message-ID: <E1772BF8-8A8D-4768-AA8C-67EE8FE21D10@vmware.com>
References: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
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
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-ID: <CF4CB55DC244AF4C900C5F414C65110B@namprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQo+IE9uIEF1ZyAxNiwgMjAxNywgYXQgMTI6MTMgQU0sIERleHVhbiBDdWkgPGRlY3VpQG1pY3Jv
c29mdC5jb20+IHdyb3RlOg0KPiANCj4gDQo+IFdpdGhvdXQgdGhlIHBhdGNoLCB2bXdfdnNvY2tf
dm1jaV90cmFuc3BvcnQua28gYW5kIHZtd192bWNpLmtvIGNhbg0KPiBhdXRvbWF0aWNhbGx5IGxv
YWQgd2hlbiBhbiBhcHBsaWNhdGlvbiBjcmVhdGVzIGFuIEFGX1ZTT0NLIHNvY2tldC4NCj4gDQo+
IFRoaXMgaXMgdGhlIGV4cGVjdGVkIGdvb2QgYmVoYXZpb3Igb24gVk13YXJlIGh5cGVydmlzb3Is
IGJ1dCBhcyB3ZQ0KPiBhcmUgZ29pbmcgdG8gYWRkIGh2X3NvY2sua28gKGkuZS4gSHlwZXItViB0
cmFuc3BvcnQgZm9yIEFGX1ZTT0NLKSwgd2UNCj4gc2hvdWxkIG1ha2Ugc3VyZSB2bXdfdnNvY2tf
dm1jaV90cmFuc3BvcnQua28gZG9lc24ndCBsb2FkIG9uIEh5cGVyLVYsDQo+IG90aGVyd2lzZSB0
aGVyZSBpcyBhIC1FQlVTWSBjb25mbGljdCB3aGVuIGJvdGggdm13X3Zzb2NrX3ZtY2lfdHJhbnNw
b3J0LmtvDQo+IGFuZCBodl9zb2NrLmtvIHRyeSB0byBjYWxsIHZzb2NrX2NvcmVfaW5pdCgpIG9u
IEh5cGVyLVYuDQoNClRoZSBWTUNJIGRyaXZlciAodm13X3ZtY2kua28pIGlzIHVzZWQgYm90aCBi
eSB0aGUgVk13YXJlIGd1ZXN0IHN1cHBvcnQgKFZNd2FyZSBUb29scyBwcmltYXJpbHkpIGFuZCBi
eSBvdXIgV29ya3N0YXRpb24gcHJvZHVjdC4gQWx3YXlzIGRpc2FibGluZyB0aGUgVk1DSSBkcml2
ZXIgb24gSHlwZXItViBtZWFucyB0aGF0IHVzZXIgd29u4oCZdCBiZSBhYmxlIHRvIHJ1biBXb3Jr
c3RhdGlvbiBuZXN0ZWQgaW4gTGludXggVk1zIG9uIEh5cGVyLVYuIFNpbmNlIHRoZSBWTUNJIGRy
aXZlciBpdHNlbGYgaXNu4oCZdCB0aGUgcHJvYmxlbSBoZXJlLCBtYXliZSB3ZSBjb3VsZCBtb3Zl
IHRoZSBjaGVjayB0byB2bXdfdnNvY2tfdm1jaV90cmFuc3BvcnQua28/IElkZWFsbHksIHRoZXJl
IHNob3VsZCBiZSBzb21lIHdheSBmb3IgYSB1c2VyIHRvIGhhdmUgYWNjZXNzIHRvIGJvdGggcHJv
dG9jb2xzLCBidXQgZm9yIG5vdyBkaXNhYmxpbmcgdGhlIFZNQ0kgc29ja2V0IHRyYW5zcG9ydCBm
b3IgSHlwZXItViAocG9zc2libHkgd2l0aCBhIG1vZHVsZSBvcHRpb24gdG8gc2tpcCB0aGF0IGNo
ZWNrIGFuZCBhbHdheXMgbG9hZCBpdCkgYnV0IGxlYXZpbmcgdGhlIFZNQ0kgZHJpdmVyIGZ1bmN0
aW9uYWwgd291bGQgYmUgYmV0dGVyLA0KDQpUaGFua3MsDQpKb3JnZW4=
