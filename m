From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Tue, 29 Aug 2017 02:36:25 +0000
Message-ID: <KL1P15301MB0008087A3EF0A8D037CC4D52BF9F0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822095437.GB16799@stefanha-x1.localdomain>
 <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
 <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
        "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
        "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>,
        "'devel@linuxdriverproject.org'" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        'George Zhang' <georgezhang@vmware.com>,
        'Michal Kubecek' <mkubecek@suse.cz>,
        'Asias He' <asias@redhat.com>,
        'Vitaly Kuznetsov' <vkuznets@redhat.com>,
        'Cathy Avery' <cavery@redhat.com>,
        "'jasowang@redhat.com'" <jasowang@redhat.com>,
        'Rolf Neugebauer' <rolf.neugebauer@docker.com>,
        "'Dave Scott'" <dave.scott@docker.com>,
        'Marcelo Cerri' <marcelo.cerri@canonical.com>,
        "'apw@canonical.com'" <apw@canonical.com>,
        "'
To: "'Jorgen S. Hansen'" <jhansen@vmware.com>,
        'Stefan Hajnoczi' <stefanha@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBGcm9tOiBEZXh1YW4gQ3VpDQo+IFNlbnQ6IFR1ZXNkYXksIEF1Z3VzdCAyMiwgMjAxNyAyMToy
MQ0KPiA+IC4uLg0KPiA+IC4uLg0KPiA+IFRoZSBvbmx5IHByb2JsZW0gaGVyZSB3b3VsZCBiZSB0
aGUgcG90ZW50aWFsIGZvciBhIGd1ZXN0IGFuZCBhIGhvc3QgYXBwDQo+IHRvDQo+ID4gaGF2ZSBh
IGNvbmZsaWN0IHdydCBwb3J0IG51bWJlcnMsIGV2ZW4gdGhvdWdoIHRoZXkgd291bGQgYmUgYWJs
ZSB0bw0KPiA+IG9wZXJhdGUgZmluZSwgaWYgcmVzdHJpY3RlZCB0byB0aGVpciBhcHByb3ByaWF0
ZSB0cmFuc3BvcnQuDQo+ID4NCj4gPiBUaGFua3MsDQo+ID4gSm9yZ2VuDQo+IA0KPiBIaSBKb3Jn
ZW4sIFN0ZWZhbiwNCj4gVGhhbmsgeW91IGZvciB0aGUgZGV0YWlsZWQgYW5hbHlzaXMhDQo+IFlv
dSBoYXZlIGEgbXVjaCBiZXR0ZXIgdW5kZXJzdGFuZGluZyB0aGFuIG1lIGFib3V0IHRoZSBjb21w
bGV4DQo+IHNjZW5hcmlvcy4gQ2FuIHlvdSBwbGVhc2Ugd29yayBvdXQgYSBwYXRjaD8gOi0pDQoN
CkhpIEpvcmdlbiwgU3RlZmFuLA0KTWF5IEkga25vdyB5b3VyIHBsYW4gZm9yIHRoaXM/IA0KIA0K
PiBJTU8gTGludXggZHJpdmVyIG9mIEh5cGVyLVYgc29ja2V0cyBpcyB0aGUgc2ltcGxlc3QgY2Fz
ZSwgYXMgd2Ugb25seSBoYXZlDQo+IHRoZSAidG8gaG9zdCIgb3B0aW9uICh0aGUgaG9zdCBzaWRl
IGRyaXZlciBvZiBIeXBlci1WIHNvY2tldHMgcnVucyBvbg0KPiBXaW5kb3dzIGtlcm5lbCBhbmQg
SSBkb24ndCB0aGluayB0aGUgb3RoZXIgaHlwZXJ2aXNvcnMgZW11bGF0ZQ0KPiB0aGUgZnVsbCBI
eXBlci1WIFZNQnVzIDQuMCwgd2hpY2ggaXMgcmVxdWlyZWQgdG8gc3VwcG9ydCBIeXBlci1WIHNv
Y2tldHMpLg0KPiANCj4gLS0gRGV4dWFuDQoNClRoYW5rcywNCi0tIERleHVhbg0K
