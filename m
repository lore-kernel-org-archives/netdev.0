From: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Sun, 22 Oct 2017 13:56:40 +0000
Message-ID: <1508680600.4970.26.camel@cohaesio.com>
References: <1507121766.30720.4.camel@cohaesio.com>
         <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl>
         <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
         <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
         <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
         <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl>
         <CAKgT0Uf=0yasidUfyadNSxzkhKvtxH2t83fjb-SU7OaAnrMReA@mail.gmail.com>
         <310ce203-0d65-bdf4-d9e4-897a349b3277@itcare.pl>
         <f6e2208a-4cdf-3303-5999-92186b437b62@itcare.pl>
         <1704eb26-c4c5-b196-ca7a-5265e92ae4e6@itcare.pl>
         <bd82f85a-f9b8-a09a-beab-67667b58f36a@itcare.pl>
         <7fd828d7-c586-2c32-3ba6-e0575bf9958c@itcare.pl>
         <99eba19f-327e-e01f-4f4a-87540b176e40@itcare.pl>
         <efcc51b4-f911-11ec-1c56-fcf31081f9d5@itcare.pl>
         <d79df7f2-5de4-cc37-baf0-5603f025155e@itcare.pl>
         <748b6d9d-4a3f-4eaa-ad24-27060c2e2642@itcare.pl>
         <16c9fa34-252f-e5a3-8b15-e5a8c4d8a46f@itcare.pl>
         <12670bc6-439c-7ef4-109a-fd20384b9ca2@itcare.pl>
         <bd59ccc3-2af4-6842-8d2f-169229a61470@itcare.pl>
         <888ec430-1d70-68e6-2ee8-bab53d21bb0f@itcare.pl>
         <CAKgT0Ud=GRrsNtoM0gOgzsh1uPJ7nuT9S-xbigmbUMi+iz-ufw@mail.gmail.com>
         <1508415582.1186.49.camel@cohaesio.com>
         <CAKgT0Ud1ftJ187qz_XBVnx+X_1BQTgWWe4sA307_3VmpMSSVaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "pstaszewski@itcare.pl" <pstaszewski@itcare.pl>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "pavlos.parissis@gmail.com" <pavlos.parissis@gmail.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
To: "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bender.cohaesio.com ([212.97.128.130]:46026 "EHLO
        mail.cohaesio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750984AbdJVN4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 09:56:44 -0400
In-Reply-To: <CAKgT0Ud1ftJ187qz_XBVnx+X_1BQTgWWe4sA307_3VmpMSSVaw@mail.gmail.com>
Content-Language: en-US
Content-ID: <B41CE4DB46576848A18357A9415DB126@surftown.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gdG9yLCAyMDE3LTEwLTE5IGF0IDA4OjQwIC0wNzAwLCBBbGV4YW5kZXIgRHV5Y2sgd3JvdGU6
DQo+IE9uIFRodSwgT2N0IDE5LCAyMDE3IGF0IDU6MTkgQU0sIEFuZGVycyBLLiBQZWRlcnNlbiB8
IENvaGFlc2lvDQo+IDxha3BAY29oYWVzaW8uY29tPiB3cm90ZToNCj4gPiBIaSBBbGV4LA0KPiA+
IA0KPiA+IE9uIG9ucywgMjAxNy0xMC0xOCBhdCAxNjozNyAtMDcwMCwgQWxleGFuZGVyIER1eWNr
IHdyb3RlOg0KPiA+ID4gV2hlbiB3ZSBsYXN0IHRhbGtlZCBJIGhhZCBhc2tlZCBpZiB5b3UgY291
bGQgZG8gYSBnaXQgYmlzZWN0IHRvDQo+ID4gPiBmaW5kDQo+ID4gPiB0aGUgbWVtb3J5IGxlYWsg
YW5kIHlvdSBzYWlkIHlvdSB3b3VsZCBsb29rIGludG8gaXQuIFRoZSBtb3N0DQo+ID4gPiB1c2Vm
dWwNCj4gPiA+IHdheSB0byBzb2x2ZSB0aGlzIHdvdWxkIGJlIHRvIGRvIGEgZ2l0IGJpc2VjdCBi
ZXR3ZWVuIHlvdXINCj4gPiA+IGN1cnJlbnQNCj4gPiA+IGtlcm5lbCBhbmQgdGhlIDQuMTEga2Vy
bmVsIHRvIGZpbmQgdGhlIHBvaW50IGF0IHdoaWNoIHRoaXMNCj4gPiA+IHN0YXJ0ZWQuDQo+ID4g
PiBJZg0KPiA+ID4gd2UgY2FuIGRvIHRoYXQgdGhlbiBmaXhpbmcgdGhpcyBiZWNvbWVzIG11Y2gg
c2ltcGxlciBhcyB3ZSBqdXN0DQo+ID4gPiBoYXZlDQo+ID4gPiB0byBmaXggdGhlIHBhdGNoIHRo
YXQgaW50cm9kdWNlZCB0aGUgaXNzdWUuDQo+ID4gDQo+ID4gV2UncmUgYWxzbyBzZWVpbmcgYSBz
bWFsbGVyIG1lbW9yeSBsZWFrIChhYm91dCAxIEdCIHBlciBkYXkpIHRoYW4NCj4gPiB0aGUNCj4g
PiBvcmlnaW5hbCBvbmUgZXZlbiB3aXRoIHRoZSAiRml4IG1lbW9yeSBsZWFrIHJlbGF0ZWQgZmls
dGVyDQo+ID4gcHJvZ3JhbW1pbmcNCj4gPiBzdGF0dXMiIGZpeCBhcHBsaWVkLiBTbyBmYXIgSSd2
ZSBkZXRlcm1pbmVkIHRoYXQgdGhlIGxlYWsgaXMNCj4gPiBwcmVzZW50IG9uDQo+ID4gNC4xMy43
IGFuZCB3YXMgaW50cm9kdWNlZCBiZXR3ZWVuIDQuMTEgYW5kIDQuMTIsIHNvIEknbGwgZG8gYW5v
dGhlcg0KPiA+IHJvdW5kIG9mIGJpc2VjdGlvbiB0byBpZGVudGlmeSB0aGUgcGF0Y2ggdGhhdCBp
bnRyb2R1Y2VkIHRoaXMuDQo+ID4gDQo+ID4gU2luY2UgdGhlIHJvdXRlciBtdXN0IHJ1biBmb3Ig
YSBjb3VwbGUgb2YgaG91cnMgYmVmb3JlIEkgY2FuIGJlDQo+ID4gc3VyZQ0KPiA+IHdoZXRoZXIg
YSBrZXJuZWwgaXMgZ29vZCBvciBiYWQsIGFuZCBJIGNhbid0IHJlYm9vdCBpdCBkdXJpbmcNCj4g
PiB3b3JraW5nDQo+ID4gaG91cnMsIGl0J2xsIHByb2JhYmx5IGJlIGFib3V0IGEgd2VlayBiZWZv
cmUgSSBoYXZlIGEgcmVzdWx0Lg0KPiA+IA0KPiA+IC0tDQo+ID4gVmVubGlnIGhpbHNlbiAvIEJl
c3QgUmVnYXJkcw0KPiA+IA0KPiA+IEFuZGVycyBLLiBQZWRlcnNlbg0KPiA+IFNlbmlvciBUZWNo
bmljYWwgTWFuYWdlcg0KPiANCj4gQW5kZXJzLA0KPiANCj4gSSdsbCBkbyBzb21lIGRpZ2dpbmcg
b24gbXkgc2lkZSB0byBzZWUgaWYgSSBjYW4gZmluZCBhbnkgb3RoZXIgbWVtb3J5DQo+IGxlYWtz
IHRoYXQgbWlnaHQgYmUgZmxvYXRpbmcgYXJvdW5kIGluIHRoZSBkcml2ZXIgdGhhdCBjb3VsZCBo
YXZlDQo+IGJlZW4NCj4gaW50cm9kdWNlZCBkdXJpbmcgdGhhdCB0aW1lLWZyYW1lLg0KPiANCj4g
T25lIHRoaW5nIHlvdSBtaWdodCB0cnkgdGhhdCB3b3VsZCBoZWxwIHdpdGggeW91ciB0ZXN0aW5n
IHdvdWxkIGJlIHRvDQo+IGp1c3QgZGlzYWJsZSB0aGUgQVRSIGZ1bmN0aW9uYWxpdHkgaW4gaTQw
ZS4gWW91IGNhbiBkbyB0aGF0IHdpdGggdGhlDQo+IGV0aHRvb2wgY29tbWFuZCAiZXRodG9vbCAt
LXNldC1wcml2LWZsYWdzIDxpZmFjZT4gZmxvdy1kaXJlY3Rvci1hdHINCj4gb2ZmIi4gVGhhdCBz
aG91bGQgYWxsb3cgeW91IHRvIGJpc2VjdCB0aGlzIHdpdGhvdXQgbmVlZGluZyB0byBkZWFsDQo+
IHdpdGggdGhlICJwcm9ncmFtbWluZyBzdGF0dXMiIHBhdGNoZXMgc2luY2UgeW91IHdvbid0IGJl
IHByb2dyYW1taW5nDQo+IEFUUiBmaWx0ZXJzIHdoaWNoIGlzIHdoYXQgY2F1c2VkIHRoYXQgbGVh
ay4NCj4gDQo+IFRoYW5rcyBmb3IgbG9va2luZyBpbnRvIHRoaXMuDQo+IA0KPiAtIEFsZXgNCg0K
SGkgQWxleCwNCg0KSSBiZWdhbiBiaXNlY3RpbmcsIHdoZXJlIEkgYXBwbGllZCB0aGUga25vd24g
Zml4IHBhdGNoZXMgdG8gdGhlIHN0ZXBzLA0Kd2hlcmUgdGhleSB3ZXJlIGFwcGxpY2FibGUgKGku
ZS4gd2l0aG91dCBjaGFuZ2luZyB0aGUgZmxvdy1kaXJlY3Rvci1hdHIgDQpmbGFnKSwgYnV0IHNv
bWUgb2YgdGhlIHN0ZXBzIGhhZCBhIGhpZ2ggYW1vdW50IG9mIHBhY2tldCBkcm9wcywgd2hpY2gN
CmNhdXNlZCBwcm9ibGVtcyBmb3Igb3VyIG5ldHdvcmssIHNvIEkgY291bGRuJ3QgbGVhdmUgdGhl
bSBydW5uaW5nIGZvcg0Kc2V2ZXJhbCBob3Vycywgd2hpY2ggaXMgbmVjZXNzYXJ5IHRvIGRldGVy
bWluZSBpZiB0aGUgbGVhayBpcyBwcmVzZW50DQpvciBub3QuIFRoZSBwYXJ0IG9mIHRoZSBiaXNl
Y3Rpb24gSSBnb3QgdGhyb3VnaCBoYWQgdGhlIHNhbWUgb3V0Y29tZSBhcw0KdGhlIGxhc3QgYmlz
ZWN0aW9uLCB3aGljaCBsZWQgdG8gImk0MGU6IEZpeCBzdXBwb3J0IGZvciBmbG93DQpkaXJlY3Rv
ciBwcm9ncmFtbWluZyBzdGF0dXMiLg0KDQpBZnRlciB0aGF0IEkgZXhwZXJpbWVudGVkIGEgYml0
IHdpdGggdGhlIGZsb3ctZGlyZWN0b3ItYXRyIGZsYWcsIGFuZCBpdA0KdHVybnMgb3V0IHRoYXQg
aWYgSSBkaXNhYmxlIHRoaXMgZmxhZyBvbiBhbGwgdGhlIE5JQ3MsIHRoZW4gdGhlIG1lbW9yeQ0K
bGVhayBpcyBnb25lLCBzbyBJIHN1c3BlY3RlZCB0aGF0IHRoZSBzbWFsbGVyIG1lbW9yeSBsZWFr
IHdhcyBhbHNvDQpjYXVzZWQgYnkgImk0MGU6IEZpeCBzdXBwb3J0IGZvciBmbG93IGRpcmVjdG9y
IHByb2dyYW1taW5nIHN0YXR1cyIuDQoNCkkgdHJpZWQgdG8gcmV2ZXJ0IHRoaXMgcGF0Y2ggZnJv
bSA0LjEzICh3aXRoIG1hbnVhbCBmaXh1cCBmb3IgdGhlIHRyYWNlDQpwb2ludCB0aGF0IGhhZCBi
ZWVuIGFkZGVkIGxhdGVyKSwgYnV0IHRoYXQgYnJvdWdodCBiYWNrIHRoZSBwYWNrZXQNCmRyb3Bz
LCBzbyBJIGNvdWxkbid0IGxldCBpdCBydW4uDQoNClRoaXMgbW9ybmluZyBJIHNhdyB5b3VyICJp
NDBlOiBBZGQgcHJvZ3JhbW1pbmcgZGVzY3JpcHRvcnMgdG8NCmNsZWFuZWRfY291bnQiIHBhdGNo
LCBzbyBJIHRyaWVkIDQuMTMuOSB3aXRoIHRoYXQgcGF0Y2ggYW5kIHRoZQ0KcHJldmlvdXMgImk0
MGU6IEZpeCBtZW1vcnkgbGVhayByZWxhdGVkIGZpbHRlciBwcm9ncmFtbWluZyBzdGF0dXMiDQp3
aXRob3V0IHR1cm5pbmcgb2ZmIHRoZSBmbG93LWRpcmVjdG9yLWF0ciBmbGFnLiBTbyBmYXIgdGhp
cyBjb21iaW5hdGlvbg0KaXMgcnVubmluZyBzdGFibGUgd2l0aG91dCBhbnkgbWVtb3J5IGxlYWtz
Lg0KDQpUaGFua3MgZm9yIGZpeGluZyB0aGlzLg0KDQpSZWdhcmRzLA0KQW5kZXJz
