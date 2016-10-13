From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: igb driver can cause cache invalidation of non-owned memory?
Date: Thu, 13 Oct 2016 10:39:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB01E773C@AcuExch.aculab.com>
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
 <063D6719AE5E284EB5DD2968C1650D6DB01E6F0F@AcuExch.aculab.com>
 <cbd0f41d-bc01-3f93-9171-2795c61afdc9@cogentembedded.com>
 <CAKgT0UdqwpjP0b4knt2d4DqS1Z9dR+vg-smkgBTZDeACGGdx=Q@mail.gmail.com>
 <d34b7175-1024-8cc9-d422-d9f75f56c069@cogentembedded.com>
 <CAKgT0UdMG4D8CZCVhBD7vF+E5aOk7zyPEp1xXaBukg3v0aYfFg@mail.gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:62412 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753567AbcJMKkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 06:40:06 -0400
In-Reply-To: <CAKgT0UdMG4D8CZCVhBD7vF+E5aOk7zyPEp1xXaBukg3v0aYfFg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQo+IFNlbnQ6IDEyIE9jdG9iZXIgMjAxNiAxOTozMA0KPiBP
biBXZWQsIE9jdCAxMiwgMjAxNiBhdCAxMToxMiBBTSwgTmlraXRhIFl1c2hjaGVua28NCj4gPG5p
a2l0YS55b3VzaEBjb2dlbnRlbWJlZGRlZC5jb20+IHdyb3RlOg0KPiA+PiBJdCB3b3VsZCBtYWtl
IG1vcmUgc2Vuc2UgdG8gdXBkYXRlIHRoZSBETUEgQVBJIGZvcg0KPiA+PiBfX2RtYV9wYWdlX2Nw
dV90b19kZXYgb24gQVJNIHNvIHRoYXQgeW91IGRvbid0IGludmFsaWRhdGUgdGhlIGNhY2hlIGlm
DQo+ID4+IHRoZSBkaXJlY3Rpb24gaXMgRE1BX0ZST01fREVWSUNFLg0KPiA+DQo+ID4gTm8sIGlu
IGdlbmVyaWMgY2FzZSBpdCdzIHVuc2FmZS4NCj4gPg0KPiA+IElmIENQVSBpc3N1ZWQgYSB3cml0
ZSB0byBhIGxvY2F0aW9uLCBhbmQgc29tZXRpbWUgbGF0ZXIgdGhhdCBsb2NhdGlvbiBpcw0KPiA+
IHVzZWQgYXMgRE1BIGJ1ZmZlciwgdGhlcmUgaXMgZGFuZ2VyIHRoYXQgd3JpdGUgaXMgc3RpbGwg
aW4gY2FjaGUgb25seSwNCj4gPiBhbmQgd3JpdGViYWNrIGlzIHBlbmRpbmcuIExhdGVyIHRoaXMg
d3JpdGViYWNrIGNhbiBvdmVyd3JpdGUgZGF0YQ0KPiA+IHdyaXR0ZW4gdG8gbWVtb3J5IHZpYSBE
TUEsIGNhdXNpbmcgY29ycnVwdGlvbi4NCj4gDQo+IE9rYXkgc28gaWYgSSB1bmRlcnN0YW5kIGl0
IGNvcnJlY3RseSB0aGVuIHRoZSBpbnZhbGlkYXRpb24gaW4NCj4gc3luY19mb3JfZGV2aWNlIGlz
IHRvIGZvcmNlIGFueSB3cml0ZXMgdG8gYmUgZmx1c2hlZCBvdXQsIGFuZCB0aGUNCj4gaW52YWxp
ZGF0aW9uIGluIHN5bmNfZm9yX2NwdSBpcyB0byBmbHVzaCBvdXQgYW55IHNwZWN1bGF0aXZlIHJl
YWRzLg0KPiBTbyB3aXRob3V0IHNwZWN1bGF0aXZlIHJlYWRzIHRoZW4gdGhlIHN5bmNfZm9yX2Nw
dSBwb3J0aW9uIGlzIG5vdA0KPiBuZWVkZWQuICBZb3UgbWlnaHQgd2FudCB0byBkZXRlcm1pbmUg
aWYgdGhlIGNvcmUgeW91IGFyZSB1c2luZw0KPiBzdXBwb3J0cyB0aGUgc3BlY3VsYXRpdmUgcmVh
ZHMsIGlmIG5vdCB5b3UgbWlnaHQgYmUgYWJsZSB0byBnZXQgYXdheQ0KPiB3aXRob3V0IGhhdmlu
ZyB0byBkbyB0aGUgc3luY19mb3JfY3B1IGF0IGFsbC4NCg0KRm9yIHJlYWRzIHRoZSBzeW5jX2Zv
cl9kZXZpY2UgaW52YWxpZGF0ZXMgKGllIGRpc2NhcmRzIHRoZSBjb250ZW50cyBvZikNCnRoZSBj
YWNoZSBsaW5lcyB0byBlbnN1cmUgdGhlIGNwdSB3b24ndCB3cml0ZSBiYWNrIGRpcnR5IGxpbmVz
Lg0KVGhlIHN5bmNfZm9yX2NwdSBpbnZhbGlkYXRlcyB0aGUgY2FjaGUgdG8gZW5zdXJlIHRoZSBj
cHUgYWN0dWFsbHkNCnJlYWRzIGZyb20gbWVtb3J5Lg0KDQpGb3Igd3JpdGVzIHlvdSBuZWVkIHRv
IGZsdXNoICh3cml0ZSBiYWNrKSBjYWNoZSBsaW5lcyBwcmlvciB0byB0aGUgRE1BLg0KSSBkb24n
dCB0aGluayBhbnl0aGluZyBpcyBuZWVkZWQgd2hlbiB0aGUgdHJhbnNmZXIgZmluaXNoZXMuDQoN
CklmIGhlYWRlcnMvdHJhaWxlcnMgbWlnaHQgYmUgYWRkZWQgdGhlIHN5bmNfZm9yX2RldmljZSBt
dXN0IGNvdmVyDQp0aGUgZW50aXJlIGFyZWEgdGhlIGZyYW1lIHdpbGwgYmUgd3JpdHRlbiB0by4N
CkNsZWFybHkgdGhlIHN5bmNfZm9yX2NwdSBuZWVkIG9ubHkgY292ZXIgdGhlIHZhbGlkIGZyYW1l
IGRhdGEuDQpJIHN1c3BlY3QgeW91IGNhbiBzYWZlbHkgc2tpcCB0aGUgc3luY19mb3JfZGV2aWNl
IGluIHRoZSAnY29weWJyZWFrJw0KcGF0aCBidXQgbm90IGlmIHRoZSBmcmFtZSBpcyBwYXNzZWQg
dXAgdGhlIHByb3RvY29sIHN0YWNrLg0KDQoJRGF2aWQNCg0K
