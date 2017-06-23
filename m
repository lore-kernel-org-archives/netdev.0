From: Rohit Vaswani <rvaswani@nvidia.com>
Subject: RE: Bluetooth: might sleep error in hidp_session_thread
Date: Fri, 23 Jun 2017 18:00:16 +0000
Message-ID: <cc75d14021724c2d8b74a92482d67b7b@HQMAIL105.nvidia.com>
References: <7be134d7f9904082a35a9cc926ec24d3@HQMAIL106.nvidia.com>
 <594D0BDE.10102@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Brian Norris <briannorris@chromium.org>,
        Douglas Anderson <dianders@chromium.org>,
        Johan Hedberg <johan.hedberg@intel.com>,
        "Peter Hurley" <peter@hurleysoftware.com>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Marcel Holtmann <marcel@holtmann.org>,
        "Gustavo Padovan" <gustavo@padovan.org>
To: jeffy <jeffy.chen@rock-chips.com>,
        "linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <594D0BDE.10102@rock-chips.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SSBkb24ndCBoYXZlIGEgd2F5IHRvIHJlcGx5IGJhY2sgdG8gdGhlIG9sZGVyIG1lc3NhZ2U7IGJ1
dCB5b3UgY2FuIHVzZSBieSB0ZXN0ZWQtYnkgZm9yIHRoZSBiZWxvdyBwYXRjaCBhbmQgcmUtc2Vu
ZDoNCg0KRm9yIHBhdGNoOiBbdjQsMy8zXSBCbHVldG9vdGg6IGhpZHA6IGZpeCBwb3NzaWJsZSBt
aWdodCBzbGVlcCBlcnJvciBpbiBoaWRwX3Nlc3Npb25fdGhyZWFkDQoNClRlc3RlZC1ieTogUm9o
aXQgVmFzd2FuaSA8cnZhc3dhbmlAbnZpZGlhLmNvbT4NCg0KLVJvaGl0DQoNCi0tLS0tT3JpZ2lu
YWwgTWVzc2FnZS0tLS0tDQpGcm9tOiBqZWZmeSBbbWFpbHRvOmplZmZ5LmNoZW5Acm9jay1jaGlw
cy5jb21dIA0KU2VudDogRnJpZGF5LCBKdW5lIDIzLCAyMDE3IDA1OjM5DQpUbzogUm9oaXQgVmFz
d2FuaTsgbGludXgtYmx1ZXRvb3RoQHZnZXIua2VybmVsLm9yZw0KQ2M6IEJyaWFuIE5vcnJpczsg
RG91Z2xhcyBBbmRlcnNvbjsgSm9oYW4gSGVkYmVyZzsgUGV0ZXIgSHVybGV5OyBKb2hhbiBIZWRi
ZXJnOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3Jn
OyBEYXZpZCBTLiBNaWxsZXI7IE1hcmNlbCBIb2x0bWFubjsgR3VzdGF2byBQYWRvdmFuDQpTdWJq
ZWN0OiBSZTogQmx1ZXRvb3RoOiBtaWdodCBzbGVlcCBlcnJvciBpbiBoaWRwX3Nlc3Npb25fdGhy
ZWFkDQoNCkhpIFJvaGl0LA0KDQpUaGFueCBmb3IgeW91ciByZXBseSwgYW5kIHNvcnJ5IHRvIHRo
ZSBkZWxheSwgc29tZWhvdyB5b3VyIG1haWwgd2FzIG1hcmtlZCBhcyBzcGFtIGJ5IHRoZSBtYWls
IHNlcnZlciA6KA0KDQpPbiAwNi8xMy8yMDE3IDAyOjMxIEFNLCBSb2hpdCBWYXN3YW5pIHdyb3Rl
Og0KPiBIaSBKZWZmeSwNCj4NCj4gSSB3YXMgbG9va2luZyBpbnRvIHRoZSBwYXRjaCBmcm9tIEpl
ZmZ5IENoZW4gZnJvbSBGZWJydWFyeSAxNCAyMDE3ICA6DQo+ICAgW3Y0LDMvM10gQmx1ZXRvb3Ro
OiBoaWRwOiBmaXggcG9zc2libGUgbWlnaHQgc2xlZXAgZXJyb3IgaW4gDQo+IGhpZHBfc2Vzc2lv
bl90aHJlYWQ6IGh0dHBzOi8vcGF0Y2h3b3JrLmtlcm5lbC5vcmcvcGF0Y2gvOTU3MDkzMS8NCj4N
Cj4gV2UgZmFjZWQgYSBzaW1pbGFyIGlzc3VlIGFuZCB0aGlzIHBhdGNoIHNlZW1zIHRvIGZpeCB0
aGUgcHJvYmxlbSBpbiBvdXIgcHJlbGltaW5hcnkgdGVzdC4NCj4gSSBhbSB0cnlpbmcgdG8gY2hl
Y2sgaWYgdGhlcmUgd2FzIGEgcmVhc29uIHRoaXMgd2Fzbid0IG1lcmdlZCBlYXJsaWVyID8NCg0K
aG1tLCBpJ20gbm90IHN1cmUgd2h5LCBidXQgcGxlYXNlIGZlZWwgZnJlZSB0byBhZGQgeW91ciB0
ZXN0LWJ5fg0KPg0KPiBUaGFua3MsDQo+IFJvaGl0DQo+DQo+IG52cHVibGljDQo+DQo+DQo+DQoN
Cg0K
