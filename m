From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: igb driver can cause cache invalidation of non-owned memory?
Date: Wed, 12 Oct 2016 16:03:39 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E6F0F@AcuExch.aculab.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net>
 <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net>
 <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com>
 <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com>
 <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
 <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com>
 <CAKgT0UfPC_uAn5=+0iiAOGyY7QA-4NWAmedVmWf6TGnywjJR8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chris Healy <cphealy@gmail.com>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UfPC_uAn5=+0iiAOGyY7QA-4NWAmedVmWf6TGnywjJR8A@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDEyIE9jdG9iZXIgMjAxNiAxNjozMw0KLi4u
DQo+ID4gVG8gZ2V0IHNvbWUgdGhyb3VnaHB1dCBpbXByb3ZlbWVudCwgSSBwcm9wb3NlIHJlbW92
YWwgb2YgdGhhdA0KPiA+IHN5bmNfZm9yX2RldmljZSgpIGJlZm9yZSByZXVzaW5nIGJ1ZmZlci4g
V2lsbCB5b3UgYWNjZXB0IHN1Y2ggYSBwYXRjaCA7KQ0KPiANCj4gTm90IG9uZSB0aGF0IGdldHMg
cmlkIG9mIHN5bmNfZm9yX2RldmljZSgpIGluIHRoZSBkcml2ZXIuICBGcm9tIHdoYXQgSQ0KPiBj
YW4gdGVsbCB0aGVyZSBhcmUgc29tZSBETUEgQVBJcyB0aGF0IHVzZSB0aGF0IHRvIHBlcmZvcm0g
dGhlDQo+IGludmFsaWRhdGlvbiBvbiB0aGUgcmVnaW9uIG9mIG1lbW9yeSBzbyB0aGF0IGl0IGNh
biBiZSBETUFlZCBpbnRvLg0KPiBXaXRob3V0IHRoYXQgd2UgcnVuIHRoZSByaXNrIG9mIGhhdmlu
ZyBhIHJhY2UgYmV0d2VlbiBzb21ldGhpbmcgdGhlDQo+IENQVSBtaWdodCBoYXZlIHBsYWNlZCBp
biB0aGUgY2FjaGUgYW5kIHNvbWV0aGluZyB0aGUgZGV2aWNlIHdyb3RlIGludG8NCj4gbWVtb3J5
LiAgVGhlIHN5bmNfZm9yX2RldmljZSgpIGNhbGwgaXMgbWVhbnQgdG8gaW52YWxpZGF0ZSB0aGUg
Y2FjaGUNCj4gZm9yIHRoZSByZWdpb24gc28gdGhhdCB3aGVuIHRoZSBkZXZpY2Ugd3JpdGVzIGlu
dG8gbWVtb3J5IHRoZXJlIGlzIG5vDQo+IHJpc2sgb2YgdGhhdCByYWNlLg0KDQpJJ20gbm90IGV4
cGVydCwgYnV0IHNvbWUgdGhvdWdodC4uLg0KDQpKdXN0IHJlbWVtYmVyIHRoYXQgdGhlIGNwdSBj
YW4gZG8gc3BlY3VsYXRpdmUgbWVtb3J5IGFuZCBjYWNoZSBsaW5lIHJlYWRzLg0KU28geW91IG5l
ZWQgdG8gZW5zdXJlIHRoZXJlIGFyZSBubyBkaXJ0eSBjYWNoZSBsaW5lcyB3aGVuIHRoZSByZWNl
aXZlDQpidWZmZXIgaXMgc2V0dXAgYW5kIG5vIGNhY2hlIGxpbmVzIGF0IGFsbCBhdCBiZWZvcmUg
bG9va2luZyBhdCB0aGUgZnJhbWUuDQoNClNvIHVubGVzcyB5b3Uga25vdyB0aGUgZXhhY3QgcnVs
ZXMgZm9yIHRoZXNlIHNwZWN1bGF0aXZlIGNhY2hlIGxpbmUgcmVhZHMNCnlvdSBoYXZlIHRvIGlu
dmFsaWRhdGUgdGhlIGNhY2hlIGFmdGVyIHRoZSBidWZmZXIgaXMgd3JpdHRlbiB0byBieSB0aGUN
CmhhcmR3YXJlIGV2ZW4gaXQgd2FzIGludmFsaWRhdGVkIHdoZW4gdGhlIGJ1ZmZlciB3YXMgc2V0
IHVwLg0KDQpJZiB5b3UgY2FuIDEwMCUgZ3VhcmFudGVlIHRoZSBjcHUgaGFzbid0IGRpcnRpZWQg
dGhlIGNhY2hlIHRoZW4gSQ0KdGhpbmsgdGhlIGludmFsaWRhdGUgcHJpb3IgdG8gcmV1c2luZyB0
aGUgYnVmZmVyIGNhbiBiZSBza2lwcGVkLg0KQnV0IEkgd291bGRuJ3Qgd2FudCB0byBkZWJ1ZyB0
aGF0IGdvaW5nIHdyb25nLg0KTWlnaHQgYmUgcHJvdmFibGUgc2FmZSBpbiB0aGUgJ2NvcHlicmVh
aycgcGF0aC4NCg0KCURhdmlkDQoNCg==
