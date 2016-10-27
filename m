From: "Mody, Rasesh" <Rasesh.Mody@cavium.com>
Subject: RE: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Thu, 27 Oct 2016 18:16:56 +0000
Message-ID: <BLUPR0701MB1572F3F88329B109F2A6C29C9FAA0@BLUPR0701MB1572.namprd07.prod.outlook.com>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
        <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
        <20161026120021.GA4402@x1>
 <f055c961-58ca-ea81-46d8-610fa055cce8@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "dvteam@molgen.mpg.de" <dvteam@molgen.mpg.de>,
        "Dept-HSGLinuxNICDev@qlogic.com" <Dept-HSGLinuxNICDev@qlogic.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>, Baoquan He <bhe@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0062.outbound.protection.outlook.com ([104.47.40.62]:53209
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935158AbcJ0SuG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Oct 2016 14:50:06 -0400
In-Reply-To: <f055c961-58ca-ea81-46d8-610fa055cce8@molgen.mpg.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBkZXB0X2hzZ19saW51eF9uaWNfZGV2LWJvdW5jZXNAcWxjbGlzdHNlcnZlci5xbG9n
aWMuY29tDQo+IFttYWlsdG86ZGVwdF9oc2dfbGludXhfbmljX2Rldi1ib3VuY2VzQHFsY2xpc3Rz
ZXJ2ZXIucWxvZ2ljLmNvbV0gT24NCj4gQmVoYWxmIE9mIFBhdWwgTWVuemVsDQo+IA0KPiBEZWFy
IEJhb3F1YW4sDQo+IA0KPiANCj4gT24gMTAvMjYvMTYgMTQ6MDAsIEJhb3F1YW4gSGUgd3JvdGU6
DQo+IA0KPiA+IE9uIDEwLzI2LzE2IGF0IDEyOjMxcG0sIFBhdWwgTWVuemVsIHdyb3RlOg0KPiA+
Pj4+ICAgICAgICAgZGV2LT5od19mZWF0dXJlcyA9IE5FVElGX0ZfSVBfQ1NVTSB8IE5FVElGX0Zf
U0cgfCBAQA0KPiA+Pj4+IC04NjA3LDYgKzg2MDgsNyBAQCBibngyX2luaXRfb25lKHN0cnVjdCBw
Y2lfZGV2ICpwZGV2LCBjb25zdCBzdHJ1Y3QNCj4gPj4+PiBwY2lfZGV2aWNlX2lkICplbnQpDQo+
ID4+Pj4gICAgICAgICByZXR1cm4gMDsNCj4gPj4+Pg0KPiA+Pj4+ICBlcnJvcjoNCj4gPj4+PiAr
ICAgICAgIGJueDJfcmVsZWFzZV9maXJtd2FyZShicCk7DQo+ID4+Pj4gICAgICAgICBwY2lfaW91
bm1hcChwZGV2LCBicC0+cmVndmlldyk7DQo+ID4+Pj4gICAgICAgICBwY2lfcmVsZWFzZV9yZWdp
b25zKHBkZXYpOw0KPiA+Pj4+ICAgICAgICAgcGNpX2Rpc2FibGVfZGV2aWNlKHBkZXYpOw0KPiA+
Pg0KPiA+PiBCYW9xdWFuLCBjb3VsZCB5b3UgcGxlYXNlIGZpeCB0aGlzIHJlZ3Jlc3Npb24uIE15
IHN1Z2dlc3Rpb24gaXMsIHRoYXQNCj4gPj4geW91IGFkZCB0aGUgb2xkIGNvZGUgYmFjaywgYnV0
IGNoZWNrIGlmIHRoZSBmaXJtd2FyZSBoYXMgYmVlbiBsb2FkZWQuDQo+ID4+IElmIGl0IGhhc27i
gJl0LCBsb2FkIGl0IGFnYWluLg0KPiA+Pg0KPiA+PiBUaGF0IHdheSwgcGVvcGxlIGNhbiB1cGRh
dGUgdGhlaXIgTGludXgga2VybmVsLCBhbmQgaXQgY29udGludWVzDQo+ID4+IHdvcmtpbmcgd2l0
aG91dCBjaGFuZ2luZyB0aGUgaW5pdHJhbWZzLCBvciBhbnl0aGluZyBlbHNlLg0KPiA+DQo+ID4g
SSBzYXcgeW91ciBtYWlsIGJ1dCBJIGFtIGFsc28gbm90IGZhbWlsaWFyIHdpdGggYm54MiBkcml2
ZXIuIEFzIHRoZQ0KPiA+IGNvbW1pdCBsb2cgc2F5cyBJIGp1c3QgdHJpZWQgdG8gbWFrZSBibngy
IGRyaXZlciByZXNldCBpdHNlbGYgZWFybGllci4NCj4gPg0KPiA+IFNvIHlvdSBkaWQgYSBnaXQg
YmlzZWN0IGFuZCBmb3VuZCB0aGlzIGNvbW1pdCBjYXVzZWQgdGhlIHJlZ3Jlc3Npb24sDQo+ID4g
cmlnaHQ/IElmIHllcywgYW5kIG5ldHdvcmsgZGV2ZWxvcGVycyBoYXZlIG5vIGFjdGlvbiwgSSB3
aWxsIGxvb2sgaW50bw0KPiA+IHRoZSBjb2RlIGFuZCBzZWUgaWYgSSBoYXZlIGlkZWEgdG8gZml4
IGl0Lg0KPiANCj4gV2VsbCwgSSBsb29rZWQgdGhyb3VnaCB0aGUgY29tbWl0cyBhbmQgZm91bmQg
dGhhdCBvbmUsIHdoaWNoIHdvdWxkIGV4cGxhaW4NCj4gdGhlIGNoYW5nZWQgYmVoYXZpb3IuDQo+
IA0KPiBUbyBiZSBzdXJlLCBhbmQgdG8gZm9sbG93IHlvdXIgcmVxdWVzdCwgSSB0b29rIExpbnV4
IDQuOC40IGFuZCByZXZlcnRlZCB5b3VyDQo+IGNvbW1pdCAoYXR0YWNoZWQpLiBUaGVuIEkgZGVs
ZXRlZCB0aGUgZmlybXdhcmUgYWdhaW4gZnJvbSB0aGUgaW5pdHJhbWZzLA0KPiBhbmQgcmVib290
ZWQuIFRoZSBkZXZpY2VzIHNob3dlZCB1cCBqdXN0IGZpbmUgYXMgYmVmb3JlLg0KDQpUaGFua3Mg
UGF1bCENCkFja2VkLWJ5OiBSYXNlc2ggTW9keSA8UmFzZXNoLk1vZHlAY2F2aXVtLmNvbT4NCg0K
PiBTbyB0byBzdW1tYXJpemUsIHRoZSBjb21taXQgaXMgaW5kZWVkIHRoZSBjdWxwcml0Lg0KPiAN
Cj4gVGhhbmsgeW91IGZvciBsb29raW5nIGludG8gdGhpcy4NCj4gDQo+IA0KPiBLaW5kIHJlZ2Fy
ZHMsDQo+IA0KPiBQYXVsDQo=
