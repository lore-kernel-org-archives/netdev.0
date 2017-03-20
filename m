From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] i40e: fix memcpy with swapped
 arguments
Date: Mon, 20 Mar 2017 23:33:06 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857DAF748@ORSMSX115.amr.corp.intel.com>
References: <20170320144627.11524-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63957 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754209AbdCTXeH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:34:07 -0400
In-Reply-To: <20170320144627.11524-1-colin.king@canonical.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBJbnRlbC13aXJlZC1sYW4gW21h
aWx0bzppbnRlbC13aXJlZC1sYW4tYm91bmNlc0BsaXN0cy5vc3Vvc2wub3JnXSBPbg0KPiBCZWhh
bGYgT2YgQ29saW4gS2luZw0KPiBTZW50OiBNb25kYXksIE1hcmNoIDIwLCAyMDE3IDc6NDYgQU0N
Cj4gVG86IEtpcnNoZXIsIEplZmZyZXkgVCA8amVmZnJleS50LmtpcnNoZXJAaW50ZWwuY29tPjsg
aW50ZWwtd2lyZWQtDQo+IGxhbkBsaXN0cy5vc3Vvc2wub3JnOyBuZXRkZXZAdmdlci5rZXJuZWwu
b3JnDQo+IENjOiBrZXJuZWwtamFuaXRvcnNAdmdlci5rZXJuZWwub3JnOyBsaW51eC1rZXJuZWxA
dmdlci5rZXJuZWwub3JnDQo+IFN1YmplY3Q6IFtJbnRlbC13aXJlZC1sYW5dIFtQQVRDSF0gaTQw
ZTogZml4IG1lbWNweSB3aXRoIHN3YXBwZWQgYXJndW1lbnRzDQo+IA0KPiBGcm9tOiBDb2xpbiBJ
YW4gS2luZyA8Y29saW4ua2luZ0BjYW5vbmljYWwuY29tPg0KDQpIaSB0aGVyZSwNCg0KPiANCj4g
VGhlIGN1cnJlbnQgY29kZSBjb3BpZXMgYW4gdW5pbml0aWFsaXplZCBwYXJhbXMgaW50bw0KPiBj
ZGV2LT5sYW5faW5mby5wYXJhbXMgYW5kIHRoZW4gcGFzc2VzIHRoZSB1bmluaXRpYWxpemVkIHBh
cmFtcw0KPiB0byB0aGUgY2FsbCBjZGV2LT5jbGllbnQtPm9wcy0+bDJfcGFyYW1fY2hhbmdlLiAg
SSBiZWxpZXZlIHRoZQ0KPiBvcmRlciBvZiB0aGUgc291cmNlIGFuZCBkZXN0aW5hdGlvbiBpbiB0
aGUgbWVtY3B5IGlzIHRoZSB3cm9uZw0KPiB3YXkgYXJvdW5kIGFuZCBzaG91bGQgYmUgc3dhcHBl
ZC4NCj4gDQoNClNvIHlvdSBhcmUgY29ycmVjdCB0aGF0IHBhcmFtcyBpcyB1bmluaXRpYWxpemVk
LiBIb3dldmVyLCB0aGUgZml4IGhlcmUgaXMgbm90IGNvcnJlY3QuIFNvbWVob3cgd2UgZHJvcHBl
ZCB0aGUgY29kZSBmb3IgaW5pdGlhbGl6aW5nIHRoZSBwYXJhbWV0ZXJzLg0KDQpTZWUgY29tbWl0
IGQ3Y2U2NDIyZDZlNiAoImk0MGU6IGRvbid0IGNoZWNrIHBhcmFtcyB1bnRpbCBhZnRlciBjaGVj
a2luZyBmb3IgY2xpZW50IGluc3RhbmNlIiwgMjAxNy0wMi0wOSkgSXQgbG9va3MgbGlrZSB0aGUg
Y29tbWl0IGl0c2VsZiB3YXMgbWFsZm9ybWVkIHdoZW4gYXBwbGllZCB1cHN0cmVhbSwgYW5kIGEg
bGF0ZXIgY29tbWl0IHdoaWNoIHNob3VsZCBoYXZlIHByZXNlcnZlZCB0aGUgY2hhbmdlcyAzMTQw
YWE5YTc4YzkgKCJpNDBlOiBLSVNTIHRoZSBjbGllbnQgaW50ZXJmYWNlIiwgMjAxNy0wMy0xNCkg
YWNjaWRlbnRhbGx5IGRyb3BwZWQgdGhlbS4NCg0KSSdsbCBwcm92aWRlIGEgcGF0Y2ggdG8gZ2V0
IHRoaXMgYmFjayBpbnRvIHRoZSBjb3JyZWN0IHN0YXRlLg0KDQpUaGFua3MgZm9yIGNhdGNoaW5n
IHRoaXMuDQoNClJlZ2FyZHMsDQpKYWtlDQo=
