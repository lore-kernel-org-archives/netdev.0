From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: Re: [PATCH net] igb: Fix Null-pointer dereference in
 igb_reset_q_vector
Date: Tue, 18 Feb 2014 23:57:32 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B73157E33@ORSMSX101.amr.corp.intel.com>
References: <1392728817-21693-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33922 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbaBRX5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 18:57:52 -0500
In-Reply-To: <1392728817-21693-1-git-send-email-christoph.paasch@uclouvain.be>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCAyMDE0LTAyLTE4IGF0IDE0OjA2ICswMTAwLCBDaHJpc3RvcGggUGFhc2NoIHdyb3Rl
Ogo+IFdoZW4gaWdiX3NldF9pbnRlcnJ1cHRfY2FwYWJpbGl0eSgpIGNhbGxzCj4gaWdiX3Jlc2V0
X2ludGVycnVwdF9jYXBhYmlsaXR5KCkgKGUuZy4sIGJlY2F1c2UgQ09ORklHX1BDSV9NU0kgaXMg
dW5zZXQpLAo+IG51bV9xX3ZlY3RvcnMgaGFzIGJlZW4gc2V0IGJ1dCBubyB2ZWN0b3IgaGFzIHll
dCBiZWVuIGFsbG9jYXRlZC4KPiAKPiBpZ2JfcmVzZXRfaW50ZXJydXB0X2NhcGFiaWxpdHkoKSB3
aWxsIHRoZW4gY2FsbCBpZ2JfcmVzZXRfcV92ZWN0b3IsCj4gd2hpY2ggYXNzdW1lcyB0aGF0IHRo
ZSB2ZWN0b3IgaXMgYWxsb2NhdGVkLiBBcyB0aGlzIGlzIG5vdCB0aGUgY2FzZSwgd2UKPiBhcmUg
YWNjZXNzaW5nIGEgTlVMTC1wb2ludGVyLgo+IAo+IFRoaXMgcGF0Y2ggZml4ZXMgaXQgYnkgY2hl
Y2tpbmcgdGhhdCBxX3ZlY3RvciBpcyBpbmRlZWQgZGlmZmVyZW50IGZyb20KPiBOVUxMLgo+IAo+
IEZpeGVzOiAwMmVmNmUxZDBiMDAyMyAoaWdiOiBGaXggcXVldWUgYWxsb2NhdGlvbiBtZXRob2Qg
dG8gYWNjb21tb2RhdGUgY2hhbmdpbmcgZHVyaW5nIHJ1bnRpbWUpCj4gQ2M6IENhcm9seW4gV3li
b3JueSA8Y2Fyb2x5bi53eWJvcm55QGludGVsLmNvbT4KPiBTaWduZWQtb2ZmLWJ5OiBDaHJpc3Rv
cGggUGFhc2NoIDxjaHJpc3RvcGgucGFhc2NoQHVjbG91dmFpbi5iZT4KPiAtLS0KPiAgZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaW50ZWwvaWdiL2lnYl9tYWluLmMgfCA2ICsrKysrKwo+ICAxIGZpbGUg
Y2hhbmdlZCwgNiBpbnNlcnRpb25zKCspCgpUaGFua3MgQ2hyaXN0b3BoLCBJIGhhdmUgYWRkZWQg
dGhpcyB0byBvdXIgSmVmZidzIGludGVybmFsIHF1ZXVlLgoK
