From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Wed, 6 Sep 2017 14:11:22 +0000
Message-ID: <8E47FDFD-809F-4EE9-9068-65BE50BE8BEB@vmware.com>
References: <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822095437.GB16799@stefanha-x1.localdomain>
 <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
 <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <KL1P15301MB0008087A3EF0A8D037CC4D52BF9F0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <61AE41B3-D143-46D2-8C68-009B78AF12C8@vmware.com>
 <20170831115455.GP13619@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Dexuan Cui <decui@microsoft.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        "Stephen Hemminger" <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>, Asias He <asias@redhat.com>,
        "Vitaly Kuznetsov" <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        Rolf Neugebauer <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        "Marcelo Cerri" <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831115455.GP13619@stefanha-x1.localdomain>
Content-Language: en-US
Content-ID: <0EF60686FBB6514CAB30720E2D1C6B22@namprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQo+IE9uIEF1ZyAzMSwgMjAxNywgYXQgMTo1NCBQTSwgU3RlZmFuIEhham5vY3ppIDxzdGVmYW5o
YUByZWRoYXQuY29tPiB3cm90ZToNCj4gDQo+IE9uIFR1ZSwgQXVnIDI5LCAyMDE3IGF0IDAzOjM3
OjA3UE0gKzAwMDAsIEpvcmdlbiBTLiBIYW5zZW4gd3JvdGU6DQo+Pj4gT24gQXVnIDI5LCAyMDE3
LCBhdCA0OjM2IEFNLCBEZXh1YW4gQ3VpIDxkZWN1aUBtaWNyb3NvZnQuY29tPiB3cm90ZToNCj4+
IElmIHdlIGFsbG93IG11bHRpcGxlIGhvc3Qgc2lkZSB0cmFuc3BvcnRzLCB2aXJ0aW8gaG9zdCBz
aWRlIHN1cHBvcnQgYW5kDQo+PiB2bWNpIHNob3VsZCBiZSBhYmxlIHRvIGNvZXhpc3QgcmVnYXJk
bGVzcyBvZiB0aGUgb3JkZXIgb2YgaW5pdGlhbGl6YXRpb24uDQo+IA0KPiBUaGF0IHNvdW5kcyBn
b29kIHRvIG1lLg0KPiANCj4gVGhpcyBtZWFucyBhZl92c29jay5jIG5lZWRzIHRvIGJlIGF3YXJl
IG9mIENJRCBhbGxvY2F0aW9uLiAgQ3VycmVudGx5IHRoZQ0KPiB2aG9zdF92c29jay5rbyBkcml2
ZXIgaGFuZGxlcyB0aGlzIGl0c2VsZiAoaXQga2VlcHMgYSBsaXN0IG9mIENJRHMgYW5kDQo+IGNo
ZWNrcyB0aGF0IHRoZXkgYXJlIG5vdCB1c2VkIHR3aWNlKS4gIEl0IHNob3VsZCBiZSBwb3NzaWJs
ZSB0byBtb3ZlDQo+IHRoYXQgc3RhdGUgaW50byBhZl92c29jay5jIHNvIHdlIGhhdmUgPGNpZCwg
aG9zdF90cmFuc3BvcnQ+IHBhaXJzLg0KPiANCg0KWWVzLCB0aGF0IHdhcyBteSB0aGlua2luZyBh
cyB3ZWxsLg0KDQo+IEknbSBjdXJyZW50bHkgd29ya2luZyBvbiBORlMgb3ZlciBBRl9WU09DSyBh
bmQgc29ja19kaWFnIHN1cHBvcnQgKGZvcg0KPiBzcyg4KSBhbmQgbmV0c3RhdC1saWtlIHRvb2xz
KS4NCj4gDQo+IE11bHRpLXRyYW5zcG9ydCBzdXBwb3J0IGlzIGxvd2VyIHByaW9yaXR5IGZvciBt
ZSBhdCB0aGUgbW9tZW50LiAgSSdtDQo+IGhhcHB5IHRvIHJldmlldyBwYXRjaGVzIHRob3VnaC4g
IElmIHRoZXJlIGlzIG5vIHByb2dyZXNzIG9uIHRoaXMgYnkgdGhlDQo+IGVuZCBvZiB0aGUgeWVh
ciB0aGVuIEkgd2lsbCBoYXZlIHRpbWUgdG8gd29yayBvbiBpdC4NCj4gDQoNCknigJlsbCB0cnkg
dG8gZmluZCB0aW1lIHRvIHdyaXRlIGEgbW9yZSBjb2hlcmVudCBwcm9wb3NhbCBpbiB0aGUgY29t
aW5nIHdlZWtzLA0KYW5kIHdlIGNhbiBkaXNjdXNzIHRoYXQuDQoNCj4gQXJlIGVpdGhlciBvZiB5
b3UgYXJlIGluIFByYWd1ZSwgQ3plY2ggUmVwdWJsaWMgb24gT2N0b2JlciAyNS0yNyBmb3INCj4g
TGludXggS2VybmVsIFN1bW1pdCwgT3BlbiBTb3VyY2UgU3VtbWl0IEV1cm9wZSwgRW1iZWRkZWQg
TGludXgNCj4gQ29uZmVyZW5jZSBFdXJvcGUsIEtWTSBGb3J1bSwgb3IgTWVzb3NDb24gRXVyb3Bl
Pw0KDQpObywgSSB3b27igJl0IGJlIHRoZXJlLg0KDQpUaGFua3MsDQpKb3JnZW4NCg0K
