From: "Jorgen S. Hansen" <jhansen@vmware.com>
Subject: Re: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Tue, 29 Aug 2017 15:37:07 +0000
Message-ID: <61AE41B3-D143-46D2-8C68-009B78AF12C8@vmware.com>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822095437.GB16799@stefanha-x1.localdomain>
 <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
 <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <KL1P15301MB0008087A3EF0A8D037CC4D52BF9F0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stefan Hajnoczi <stefanha@redhat.com>,
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
        "apw@canonical.com" <apw@canonical.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1P15301MB0008087A3EF0A8D037CC4D52BF9F0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-ID: <DF6C2792EAB0D14BAA5FD686F90F55C3@namprd05.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DQo+IE9uIEF1ZyAyOSwgMjAxNywgYXQgNDozNiBBTSwgRGV4dWFuIEN1aSA8ZGVjdWlAbWljcm9z
b2Z0LmNvbT4gd3JvdGU6DQo+IA0KPj4gRnJvbTogRGV4dWFuIEN1aQ0KPj4gU2VudDogVHVlc2Rh
eSwgQXVndXN0IDIyLCAyMDE3IDIxOjIxDQo+Pj4gLi4uDQo+Pj4gLi4uDQo+Pj4gVGhlIG9ubHkg
cHJvYmxlbSBoZXJlIHdvdWxkIGJlIHRoZSBwb3RlbnRpYWwgZm9yIGEgZ3Vlc3QgYW5kIGEgaG9z
dCBhcHANCj4+IHRvDQo+Pj4gaGF2ZSBhIGNvbmZsaWN0IHdydCBwb3J0IG51bWJlcnMsIGV2ZW4g
dGhvdWdoIHRoZXkgd291bGQgYmUgYWJsZSB0bw0KPj4+IG9wZXJhdGUgZmluZSwgaWYgcmVzdHJp
Y3RlZCB0byB0aGVpciBhcHByb3ByaWF0ZSB0cmFuc3BvcnQuDQo+Pj4gDQo+Pj4gVGhhbmtzLA0K
Pj4+IEpvcmdlbg0KPj4gDQo+PiBIaSBKb3JnZW4sIFN0ZWZhbiwNCj4+IFRoYW5rIHlvdSBmb3Ig
dGhlIGRldGFpbGVkIGFuYWx5c2lzIQ0KPj4gWW91IGhhdmUgYSBtdWNoIGJldHRlciB1bmRlcnN0
YW5kaW5nIHRoYW4gbWUgYWJvdXQgdGhlIGNvbXBsZXgNCj4+IHNjZW5hcmlvcy4gQ2FuIHlvdSBw
bGVhc2Ugd29yayBvdXQgYSBwYXRjaD8gOi0pDQo+IA0KPiBIaSBKb3JnZW4sIFN0ZWZhbiwNCj4g
TWF5IEkga25vdyB5b3VyIHBsYW4gZm9yIHRoaXM/IA0KDQpJ4oCZZCBiZSBoYXBweSB0byBkaXNj
dXNzIHRoaXMgbm93LCBidXQgSSBkb27igJl0IGhhdmUgdGltZSB0byB3b3JrIG9uIHRoZQ0KYWN0
dWFsIGltcGxlbWVudGF0aW9uIGluIHRoZSBuZXh0IGNvdXBsZSBvZiB3ZWVrcy4NCg0KRm9yIHRo
ZSBndWVzdCwgd2UgYWdyZWUgdGhhdCByZWdpc3RlcmluZyBhIGd1ZXN0IHRyYW5zcG9ydCBzaG91
bGQgYmUNCnRpZWQgdG8gZWl0aGVyIHRoZSBoeXBlcnZpc29yIHJ1bm5pbmcgdGhlIGd1ZXN0LCBv
ciB0aGUgZXhpc3RlbmNlIG9mDQp0aGUgYXBwcm9wcmlhdGUgdmlydHVhbCBoYXJkd2FyZS4NCg0K
TXkgbWFpbiBjb25jZXJuIGlzIHRoYXQgb3VyIGV4aXN0aW5nIHNvZnR3YXJlIHJlbGllcyBvbiB0
aGUgY3VycmVudA0KYmVoYXZpb3Igb2YgYXV0by1sb2FkaW5nIHRoZSBWTUNJIHRyYW5zcG9ydCBv
biB0aGUgaG9zdCBzaWRlLiBTbw0KY2hhbmdpbmcgdGhhdCBiZWhhdmlvciBjb3VsZCBjYXVzZSB0
cm91YmxlIGZvciBvdXIgZXhpc3RpbmcgTGludXgNCnVzZXJzLg0KDQpJ4oCZbSB3b25kZXJpbmcg
d2hldGhlciBpdCB3b3VsZCBiZSBwb3NzaWJsZSB0byBzdXBwb3J0IG11bHRpcGxlIGhvc3QNCnNp
ZGUgdHJhbnNwb3J0cy4gU2luY2UgaXQgaXMgdGhlb3JldGljYWxseSBwb3NzaWJsZSB0byBydW4g
bXVsdGlwbGUNCmh5cGVydmlzb3JzIGF0IHRoZSBzYW1lIHRpbWUsIHRoZXJlIHdvdWxkIGV2ZW4g
YmUgYSB1c2UgY2FzZSBmb3IgdGhpcy4NCg0KSWYgdGhlIGFzc2lnbm1lbnQgb2YgQ0lEcyBpcyBt
YWRlIHVuaXF1ZSBhY3Jvc3MgYWxsIHRyYW5zcG9ydHMsIGENCmNvbm5lY3Rpb24gaW5pdGlhdGVk
IGJ5IHRoZSBob3N0IHNpZGUgd2lsbCBnZXQgZGlyZWN0ZWQgdG8gdGhlDQphcHByb3ByaWF0ZSB0
cmFuc3BvcnQgYmFzZWQgb24gdGhlIENJRC4gQW55IHRyYWZmaWMgY29taW5nIGZyb20gYSBndWVz
dA0Kd2lsbCBuYXR1cmFsbHkgYmUgdXNpbmcgdGhlIGFwcHJvcHJpYXRlIHRyYW5zcG9ydC4gSG9z
dCBzaWRlIGFwcGxpY2F0aW9ucw0Kd2lsbCBoYXZlIHRvIHNoYXJlIHRoZSBwb3J0IHNwYWNlIGFz
IHdlbGwuIFRoaXMgd291bGQgcmVxdWlyZSB0cmFja2luZw0KQ0lEcyBhcyBhIGNvbW1vbiByZXNv
dXJjZSBhY3Jvc3MgYWxsIHRyYW5zcG9ydHMsIGJ1dCBtYWtlIENJRHMNCnVuaXF1ZSBWTSBhZGRy
ZXNzZXMgb24gYSBnaXZlbiBob3N0Lg0KDQpJZiB3ZSBhbGxvdyBtdWx0aXBsZSBob3N0IHNpZGUg
dHJhbnNwb3J0cywgdmlydGlvIGhvc3Qgc2lkZSBzdXBwb3J0IGFuZA0Kdm1jaSBzaG91bGQgYmUg
YWJsZSB0byBjb2V4aXN0IHJlZ2FyZGxlc3Mgb2YgdGhlIG9yZGVyIG9mIGluaXRpYWxpemF0aW9u
Lg0KDQpUaGFua3MsDQpKb3JnZW4NCg0K
