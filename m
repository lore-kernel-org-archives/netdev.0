From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [RFC PATCH 0/7] Extend socket timestamping API
Date: Thu, 13 Apr 2017 09:08:08 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857E00EB6@ORSMSX115.amr.corp.intel.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19283 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750745AbdDMJIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 05:08:10 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNaXJvc2xhdiBMaWNodmFyIFtt
YWlsdG86bWxpY2h2YXJAcmVkaGF0LmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBBcHJpbCAxMiwg
MjAxNyA3OjE4IEFNDQo+IFRvOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IENjOiBSaWNoYXJk
IENvY2hyYW4gPHJpY2hhcmRjb2NocmFuQGdtYWlsLmNvbT47IFdpbGxlbSBkZSBCcnVpam4NCj4g
PHdpbGxlbWJAZ29vZ2xlLmNvbT47IFNvaGVpbCBIYXNzYXMgWWVnYW5laCA8c29oZWlsQGdvb2ds
ZS5jb20+OyBLZWxsZXIsDQo+IEphY29iIEUgPGphY29iLmUua2VsbGVyQGludGVsLmNvbT47IERl
bm55IFBhZ2UgPGRlbm55cGFnZUBtZS5jb20+OyBKaXJpDQo+IEJlbmMgPGpiZW5jQHJlZGhhdC5j
b20+DQo+IFN1YmplY3Q6IFtSRkMgUEFUQ0ggMC83XSBFeHRlbmQgc29ja2V0IHRpbWVzdGFtcGlu
ZyBBUEkNCj4gDQo+IFRoaXMgcGF0Y2hzZXQgYWRkcyBuZXcgb3B0aW9ucyB0byB0aGUgdGltZXN0
YW1waW5nIEFQSSB0aGF0IHdpbGwgYmUNCj4gdXNlZnVsIGZvciBOVFAgaW1wbGVtZW50YXRpb25z
IGFuZCBwb3NzaWJseSBvdGhlciBhcHBsaWNhdGlvbnMuDQo+IA0KPiBUaGUgZmlyc3QgcGF0Y2gg
c3BlY2lmaWVzIGEgdGltZXN0YW1wIGZpbHRlciBmb3IgTlRQIHBhY2tldHMsIHdoaWNoIGlzDQo+
IGhhbmRsZWQgaW4gdGhlIHNlY29uZCBwYXRjaCBpbiBkcml2ZXJzIHRoYXQgY2FuIHRpbWVzdGFt
cCBhbGwgcGFja2V0cy4NCj4gVGhlcmUgaXMgbm8gYXR0ZW1wdCB0byBhZGQgdGhlIHN1cHBvcnQg
dG8gdGhlIHBoeXRlciBkcml2ZXIuDQo+IA0KPiBUaGUgdGhpcmQgcGF0Y2ggYWRkcyBhIG5ldyBv
cHRpb24gdG8gZ2V0IGluZm9ybWF0aW9uIGFib3V0DQo+IEhXLXRpbWVzdGFtcGVkIHBhY2tldHMu
IFRoZSBmb3VydGggcGF0Y2ggYWRkcyBzdXBwb3J0IGZvciB0aGlzIG9wdGlvbiB0bw0KPiB0aGUg
ZHJpdmVycyAoY3VycmVudGx5IG9ubHkgaWdiIGFuZCBlMTAwMGUpLg0KPiANCj4gVGhlIGZpZnRo
IHBhdGNoIGZpeGVzIHRoZSBjb2RlIHRvIG5vdCBtYWtlIGEgZmFsc2Ugc29mdHdhcmUgVFggdGlt
ZXN0YW1wDQo+IHdoZW4gSFcgdGltZXN0YW1waW5nIGlzIGVuYWJsZWQuIFRoZSBzaXh0aCBwYXRj
aCBkZXBlbmRzIG9uIHRoaXMgZml4Lg0KPiANCj4gVGhlIHNpeHRoIHBhdGNoIGFkZHMgYSBuZXcg
b3B0aW9uIHRvIGFsbG93IG91dGdvaW5nIHBhY2tldHMgdG8gYmUgbG9vcGVkDQo+IG11bHRpcGxl
IHRpbWVzIHRvIHRoZSBlcnJvciBxdWV1ZSBpbiBvcmRlciB0byBhbGxvdyBzaW11bHRhbmVvdXMg
U1cgYW5kDQo+IEhXIHRpbWVzdGFtcGluZy4gVGhlIHNldmVudGggcGF0Y2ggdXBkYXRlcyBkcml2
ZXJzIHRoYXQgYXNzdW1lZCBTVw0KPiB0aW1lc3RhbXBpbmcgY2Fubm90IGJlIHVzZWQgdG9nZXRo
ZXIgd2l0aCBIVyB0aW1lc3RhbXBpbmcuDQo+IA0KDQpJIHRoaW5rIHRoaXMgbG9va3MgcHJldHR5
IGdvb2QsIHN0cmFpZ2h0IGZvcndhcmQgYW5kIHVzZWZ1bC4gSSBhZ3JlZSB3aXRoIFJpY2hhcmQg
YWJvdXQgdGhlIG9uZSBjb21taXQgbWVzc2FnZSwgYnV0IHRoZSByZXN0IGxvb2tzIGdvb2QgbW9k
dWxvIG1pc3NpbmcgdXBkYXRlcyBmb3IgYWxsIHRoZSBvdGhlciBkcml2ZXJzLg0KDQpJIGRpZG4n
dCBzZWUgYW55IGNvZGUgdG8gdXBkYXRlIHRoZSBldGh0b29sIGdldF90c19pbmZvIGRhdGEgZm9y
IF9OVFBfQUxMIGVpdGhlci4NCg0KVGhhbmtzLA0KSmFrZQ0K
