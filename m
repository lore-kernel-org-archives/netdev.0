From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Wed, 6 Sep 2017 19:39:50 +0000
Message-ID: <KL1P15301MB00089961DA6FEB74D5CC6A61BF970@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
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
 <8E47FDFD-809F-4EE9-9068-65BE50BE8BEB@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Michal Kubecek <mkubecek@suse.cz>, "joe@perches.com" <joe@perches.com>,
 "olaf@aepfle.de" <olaf@aepfle.de>, Stephen Hemminger <sthemmin@microsoft.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Haiyang
 Zhang <haiyangz@microsoft.com>, Dave Scott <dave.scott@docker.com>,
 "apw@canonical.com" <apw@canonical.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Vitaly Kuznetsov <vkuznets@redhat.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 Marcelo Cerri <marcelo.cerri@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Asias He <asias@redhat.com>, "davem@davemloft.net" <davem@davemloft.net>,
 George Zhang <georgezhang@vmware.com>,
 Dan Carpenter <dan.carpenter@oracle.com>
To: "Jorgen S. Hansen" <jhansen@vmware.com>, Stefan Hajnoczi
 <stefanha@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <8E47FDFD-809F-4EE9-9068-65BE50BE8BEB@vmware.com>
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

PiBGcm9tOiBKb3JnZW4gUy4gSGFuc2VuIFttYWlsdG86amhhbnNlbkB2bXdhcmUuY29tXQ0KPiBT
ZW50OiBXZWRuZXNkYXksIFNlcHRlbWJlciA2LCAyMDE3IDc6MTEgQU0NCj4+IC4uLg0KPiA+IEkn
bSBjdXJyZW50bHkgd29ya2luZyBvbiBORlMgb3ZlciBBRl9WU09DSyBhbmQgc29ja19kaWFnIHN1
cHBvcnQgKGZvcg0KPiA+IHNzKDgpIGFuZCBuZXRzdGF0LWxpa2UgdG9vbHMpLg0KPiA+DQo+ID4g
TXVsdGktdHJhbnNwb3J0IHN1cHBvcnQgaXMgbG93ZXIgcHJpb3JpdHkgZm9yIG1lIGF0IHRoZSBt
b21lbnQuICBJJ20NCj4gPiBoYXBweSB0byByZXZpZXcgcGF0Y2hlcyB0aG91Z2guICBJZiB0aGVy
ZSBpcyBubyBwcm9ncmVzcyBvbiB0aGlzIGJ5IHRoZQ0KPiA+IGVuZCBvZiB0aGUgeWVhciB0aGVu
IEkgd2lsbCBoYXZlIHRpbWUgdG8gd29yayBvbiBpdC4NCj4gPg0KPiANCj4gSeKAmWxsIHRyeSB0
byBmaW5kIHRpbWUgdG8gd3JpdGUgYSBtb3JlIGNvaGVyZW50IHByb3Bvc2FsIGluIHRoZSBjb21p
bmcgd2Vla3MsDQo+IGFuZCB3ZSBjYW4gZGlzY3VzcyB0aGF0Lg0KPiANCj4gSm9yZ2VuDQoNClRo
YW5rIHlvdSEgDQoNClRoYW5rcywNCi0tIERleHVhbg0KX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX18KZGV2ZWwgbWFpbGluZyBsaXN0CmRldmVsQGxpbnV4ZHJp
dmVycHJvamVjdC5vcmcKaHR0cDovL2RyaXZlcmRldi5saW51eGRyaXZlcnByb2plY3Qub3JnL21h
aWxtYW4vbGlzdGluZm8vZHJpdmVyZGV2LWRldmVsCg==
