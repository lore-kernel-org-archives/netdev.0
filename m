From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net 1/8] igb: Update queue reinit function to call dev_close
 when init of queues fails
Date: Mon, 2 Dec 2013 17:39:05 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6264FA0097E@ORSMSX102.amr.corp.intel.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1385624162-10116-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20131129.154757.2160926223289559260.davem@davemloft.net>
	 <9BBC4E0CF881AA4299206E2E1412B6264FA00871@ORSMSX102.amr.corp.intel.com>
 <1386004696.1516.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11795 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855Ab3LBRjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Dec 2013 12:39:13 -0500
In-Reply-To: <1386004696.1516.15.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCZW4gSHV0Y2hpbmdzIFttYWls
dG86Ymh1dGNoaW5nc0Bzb2xhcmZsYXJlLmNvbV0NCj4gU2VudDogTW9uZGF5LCBEZWNlbWJlciAw
MiwgMjAxMyA5OjE4IEFNDQo+IFRvOiBXeWJvcm55LCBDYXJvbHluDQo+IENjOiBEYXZpZCBNaWxs
ZXI7IEtpcnNoZXIsIEplZmZyZXkgVDsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsNCj4gZ29zcG9A
cmVkaGF0LmNvbTsgc2Fzc21hbm5AcmVkaGF0LmNvbQ0KPiBTdWJqZWN0OiBSZTogW25ldCAxLzhd
IGlnYjogVXBkYXRlIHF1ZXVlIHJlaW5pdCBmdW5jdGlvbiB0byBjYWxsIGRldl9jbG9zZSB3aGVu
DQo+IGluaXQgb2YgcXVldWVzIGZhaWxzDQo+IA0KWy4uXQ0KPiBNeSBjb25jZXJucyB3ZXJlIHRo
YXQgYWZ0ZXIgYSBmYWlsdXJlIHdoZXJlIHRoZSBpbnRlcmZhY2UgaXMgZWZmZWN0aXZlbHkgZG93
biwNCj4gLSB0aGUgaW50ZXJmYWNlIG11c3QgYmUgaW4gYSBjb25zaXN0ZW50IHN0YXRlIHdoZXJl
IGlzIGl0IHNhZmUgdG8gcmVjb25maWd1cmUgdGhlDQo+IGludGVyZmFjZSBhZ2FpbiBvciB0byB1
bmJpbmQgdGhlIGRyaXZlciwgYW5kDQo+IC0gaXQgc2hvdWxkIGJlIG9idmlvdXNseSBkb3duIHNv
IHRoZSB1c2VyIGNhbiB0aGVuIHRyeSB0byBicmluZyBpdCB1cCBhZ2Fpbi4NCj4gDQo+IERhdmlk
IGlzIHNheWluZyB0aGF0IHlvdSBzaG91bGQgaW1wbGVtZW50IHRoZSByZWNvbmZpZ3VyYXRpb24g
aW4gc3VjaCBhIHdheSB0aGF0DQo+IHlvdSBjYW4gYWx3YXlzIHJvbGwgYmFjayB0byB0aGUgcHJl
dmlvdXMgd29ya2luZyBzdGF0ZSBpbiBjYXNlIG9mIGEgZmFpbHVyZSAod2hpY2gNCj4gd291bGQg
bWFrZSBteSBjb25jZXJucyBtb290KS4gIFRoaXMgaXMgZGVmaW5pdGVseSBhIGdvb2QgZ29hbCBi
dXQgSSdtIG5vdA0KPiBjb252aW5jZWQgdGhhdCBpdCdzIGFsd2F5cyBwb3NzaWJsZS4NCj4gDQpU
aGFua3MgZm9yIHRoZSBjbGFyaWZpY2F0aW9uIEJlbiwgSSdsbCBzZWUgd2hhdCBJIGNhbiBkbyB0
byBmb2xsb3cgRGF2ZSdzIGZlZWRiYWNrLg0KDQpDYXJvbHluDQo=
