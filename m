From: "Coelho, Luciano" <luciano.coelho@intel.com>
Subject: Re: [PATCH] iwlwifi: Demote messages about fw flags size to info
Date: Mon, 24 Jul 2017 11:01:27 +0000
Message-ID: <1500894086.20057.12.camel@intel.com>
References: <20170721145147.7572-1-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux@endlessm.com" <linux@endlessm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jprvita@endlessm.com" <jprvita@endlessm.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: linuxwifi <linuxwifi@intel.com>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "jprvita@gmail.com" <jprvita@gmail.com>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721145147.7572-1-jprvita@endlessm.com>
Content-Language: en-US
Content-ID: <ED09C8F58355B743A3E2E4DA4122AB19@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gRnJpLCAyMDE3LTA3LTIxIGF0IDA3OjUxIC0wNzAwLCBKb8OjbyBQYXVsbyBSZWNoaSBWaXRh
IHdyb3RlOg0KPiBUaGVzZSBtZXNzYWdlcyBhcmUgbm90IHJlcG9ydGluZyBhIHJlYWwgZXJyb3Is
IGp1c3QgdGhlIGZhY3QgdGhhdCB0aGUNCj4gZmlybXdhcmUga25vd3MgYWJvdXQgbW9yZSBmbGFn
cyB0aGVuIHRoZSBkcml2ZXIuDQo+IA0KPiBDdXJyZW50bHkgdGhlc2UgbWVzc2FnZXMgYXJlIHBy
ZXNlbnRlZCB0byB0aGUgdXNlciBkdXJpbmcgYm9vdCBpZiB0aGVyZQ0KPiBpcyBubyBib290c3Bs
YXNoIGNvdmVyaW5nIHRoZSBjb25zb2xlLCBzb21ldGltZXMgZXZlbiBpZiB0aGUgYm9vdCBzcGxh
c2gNCj4gaXMgZW5hYmxlZCBidXQgaGFzIG5vdCBzdGFydGVkIHlldCBieSB0aGUgdGltZSB0aGlz
IG1lc3NhZ2UgaXMgc2hvd24uDQo+IA0KPiBEZW1vdGluZyBpdCB0byB0aGUgaW5mbyBsZXZlbCBo
ZWxwcyBoYXZpbmcgYSBjbGVhbiBib290IHByb2Nlc3MuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBK
b8OjbyBQYXVsbyBSZWNoaSBWaXRhIDxqcHJ2aXRhQGVuZGxlc3NtLmNvbT4NCj4gLS0tDQoNClRo
ZSBpZGVhIHdpdGggdGhpcyBlcnJvciBpcyB0aGF0IGlmIHRoZSBmaXJtd2FyZSBpcyB0b28gbmV3
IGFuZCBpbmNsdWRlcw0KYSBUTFYgdGhhdCB3ZSBhcmUgbm90IGF3YXJlIG9mLCB0aGVyZSBjYW4g
YmUgdW5leHBlY3RlZCBpc3N1ZXMuICBGb3INCmluc3RhbmNlLCBzb21ldGltZXMgdGhlIEZXIEFQ
SSBjaGFuZ2VzIHNvbWUgb2YgaXRzIHN0cnVjdHVyZXMgYW5kIHdlIHVzZQ0KVExWcyB0byBrbm93
IHdoaWNoIG9uZSB0byB1c2UuICBJZiBhIG5ldyBzdHJ1Y3QgaXMgaW4gdXNlIGJ5IHRoZQ0KZmly
bXdhcmUgYnV0IG5vdCBieSB0aGUgZHJpdmVyLCBwcm9ibGVtcyB3aWxsIG9jY3VyLg0KDQpSZWNl
bnRseSB3ZSBhY2NpZGVudGFsbHkgb21pdHRlZCBvbmUgVExWIGZyb20gdGhlIGRyaXZlciBhbmQg
cmVsZWFzZWQgYQ0KbmV3IGZpcm13YXJlIHRoYXQgaGFkIGl0IHNldC4uLiBUaGF0J3MgdGhlIGVy
cm9yIHlvdSBhcmUgY3VycmVudGx5DQpzZWVpbmcuICBXZSBoYXZlIGEgYnVnemlsbGEgZW50cnlb
MV0gYW5kIGl0IGlzIGZpeGVkIGluIG91ciBpbnRlcm5hbA0KdHJlZS4gIFRoZSBmaXggd2lsbCBi
ZSBzZW50IHVwc3RyZWFtIGluIHRoZSBuZXh0IC1maXhlcyByb3VuZCB3ZSBzZW5kDQpvdXQuDQoN
ClRoaXMgc3BlY2lmaWMgY2FzZSBpcyBoYXJtbGVzcywgYnV0IEknZCByYXRoZXIga2VlcCB0aGlz
IG1lc3NhZ2UgYXMgYW4NCmVycm9yLCBiZWNhdXNlIGluIG90aGVyIHNpdHVhdGlvbnMgaXQgY291
bGQgbGVhZCB0byB1bmV4cGVjdGVkDQpiZWhhdmlvaXIsIHNvIEkgcHJlZmVyIHRvIGtlZXAgaXQg
dmVyeSB2aXNpYmxlLg0KDQoNClsxXSBodHRwczovL2J1Z3ppbGxhLmtlcm5lbC5vcmcvc2hvd19i
dWcuY2dpP2lkPTE5NjE5NQ0KDQotLQ0KQ2hlZXJzLA0KTHVjYS4=
