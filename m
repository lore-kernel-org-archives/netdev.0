From: "Singhai, Anjali" <anjali.singhai@intel.com>
Subject: RE: [net v2 2/3] i40e: Fix Rx checksum error counter
Date: Wed, 7 Jan 2015 20:14:02 +0000
Message-ID: <C40BE8378EF49C44B9184714DBC8EF2992D9668D@ORSMSX110.amr.corp.intel.com>
References: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1420594317-6191-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <CA+mtBx-VgUCCxnkayoqR6AwYXu_mfzbtGZzH+oeT3wrOznzWGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Tom Herbert <therbert@google.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:64068 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbbAGUOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 15:14:04 -0500
In-Reply-To: <CA+mtBx-VgUCCxnkayoqR6AwYXu_mfzbtGZzH+oeT3wrOznzWGg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCA2IEphbiAyMDE1IDIxOjQzOjU3IC0wODAwDQpUb20gSGVyYmVydCA8dGhlcmJlcnRA
Z29vZ2xlLmNvbT4gd3JvdGU6DQo+ID4gQEAgLTEzMzcsMTUgKzEzMzUsMTkgQEAgc3RhdGljIGlu
bGluZSB2b2lkIGk0MGVfcnhfY2hlY2tzdW0oc3RydWN0IGk0MGVfdnNpICp2c2ksDQo+ID4gICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgc2tiLT5wcm90b2NvbCA9PSBo
dG9ucyhFVEhfUF84MDIxQUQpKQ0KPiA+ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgID8gVkxBTl9ITEVOIDogMDsNCj4gPg0KPiA+IC0gICAgICAgICAgICAgICByeF91
ZHBfY3N1bSA9IHVkcF9jc3VtKHNrYik7DQo+ID4gLSAgICAgICAgICAgICAgIGlwaCA9IGlwX2hk
cihza2IpOw0KPiA+IC0gICAgICAgICAgICAgICBjc3VtID0gY3N1bV90Y3B1ZHBfbWFnaWMoDQo+
ID4gLSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBpcGgtPnNhZGRyLCBpcGgtPmRhZGRy
LA0KPiA+IC0gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKHNrYi0+bGVuIC0gc2tiX3Ry
YW5zcG9ydF9vZmZzZXQoc2tiKSksDQo+ID4gLSAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICBJUFBST1RPX1VEUCwgcnhfdWRwX2NzdW0pOw0KPiA+ICsgICAgICAgICAgICAgICBpZiAoKGlw
X2hkcihza2IpLT5wcm90b2NvbCA9PSBJUFBST1RPX1VEUCkgJiYNCj4gPiArICAgICAgICAgICAg
ICAgICAgICh1ZHBfaGRyKHNrYiktPmNoZWNrICE9IDApKSB7DQo+ID4gKyAgICAgICAgICAgICAg
ICAgICAgICAgcnhfdWRwX2NzdW0gPSB1ZHBfY3N1bShza2IpOw0KPiANCj4gRG9lc24ndCB0aGlz
IGNvbXB1dGUgdGhlIHdob2xlIGNoZWNrc3VtIG9mIHRoZSBwYWNrZXQgbWFraW5nIHRoZSBmYWN0
IA0KPiB0aGF0IGRldmljZSB2ZXJpZmllZCBpbm5lciBjaGVja3N1bSBwcmV0dHkgbXVjaCBpcnJl
bGV2YW50PyBJdCB3b3VsZCANCj4gcHJvYmFibHkgYmUganVzdCBhcyB3ZWxsIHRvIHJldHVybiBD
SEVDS1NVTV9OT05FIGFuZCBsZXQgdGhlIHN0YWNrIA0KPiBkZWFsIHdpdGggaXQgYW5kIHJlbW92
ZSBhbGwgdGhpcyBjb21wbGV4aXR5Lg0KDQpUaGlzIGlzIG9ubHkgY2FsY3VsYXRpbmcgb3V0ZXIg
VURQIGNzdW0sIGlubmVyIGNzdW1zIGFyZSBvZmZsb2FkZWQgYW5kIHNvIGlzIHRoZSBvdXRlciBJ
UCBjc3VtLiBPdmVyYWxsIHRoaXMgaXMgbGVzcyB3b3JrIHRoYW4gYXNraW5nIHRoZSBzdGFjayB0
byBkbyBhbGwgb2YgdGhvc2UgYnkgbWFya2luZyBpdCBhcyBDSEVDS1NVTV9VTk5FQ0VTU0FSWS4g
V2UgZG8gaGF2ZSBhIHBhdGNoIGluIGxpbmUgdG8gdXNlIGNzdW1fbGV2ZWwgYnV0IEkgYmVsaWV2
ZSBldmVuIHdpdGggdGhhdCB3ZSB3b3VsZCBiZSBhc2tpbmcgdGhlIHN0YWNrIHRvIGRvIG1vcmUg
d29yayB0aGFuIG5lY2Vzc2FyeSBpZiB3ZSBpbmRpY2F0ZSB0aGF0IG9ubHkgaW5uZXIgY2hlY2tz
dW1zIGFyZSBvZmZsb2FkZWQuIFdpdGggb3VyIEhXIHdlIGFyZSBhYmxlIHRvIG9mZmxvYWQgMyBv
dXQgb2YgNCBjc3Vtcy4NCg==
