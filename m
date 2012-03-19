From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [net 2/3] net: do not do gso for CHECKSUM_UNNECESSARY in
 netif_needs_gso
Date: Mon, 19 Mar 2012 15:11:07 +0000
Message-ID: <138EA028228D124A900F5E6746F3C2160F6BAF24@ORSMSX102.amr.corp.intel.com>
References: <1331975292-19521-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1332009716.3022.243.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11059 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616Ab2CSPLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 11:11:10 -0400
In-Reply-To: <1332009716.3022.243.camel@deadeye>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiANCj4gT24gU2F0LCAyMDEyLTAzLTE3IGF0IDAyOjA4IC0wNzAwLCBKZWZmIEtpcnNoZXIgd3Jv
dGU6DQo+ID4gRnJvbTogWWkgWm91IDx5aS56b3VAaW50ZWwuY29tPg0KPiA+DQo+ID4gVGhpcyBp
cyByZWxhdGVkIHRvIGZpeGluZyB0aGUgYnVnIG9mIGRyb3BwaW5nIEZDb0UgZnJhbWVzIHdoZW4N
Cj4gZGlzYWJsaW5nIHR4IGlwDQo+ID4gY2hlY2tzdW0gYnkgJ2V0aHRvb2wgLUsgZXRoeCB0eCBv
ZmYnLiBUaGUgRkNvRSBwcm90b2NvbCBzdGFjayBkcml2ZXINCj4gd291bGQNCj4gPiB1c2UgQ0hF
Q0tTVU1fVU5ORUNFU1NBUlkgb24gdHggcGF0aCBpbnN0ZWFkIG9mIENIRUNLU1VNX1BBUlRJQUwg
KGFzDQo+IGluZGljYXRlZCBpbg0KPiA+IHRoZSAyLzIgb2YgdGhpcyBzZXJpZXMpLiBUbyBkbyBz
bywgbmV0aWZfbmVlZHNfZ3NvKCkgaGFzIHRvIGJlIGNoYW5nZWQNCj4gaGVyZSB0bw0KPiA+IG5v
dCBkbyBnc28gZm9yIGJvdGggQ0hFQ0tTVU1fUEFSVElBTCBhbmQgQ0hFQ0tTVU1fVU5ORUNFU1NB
UlkuDQo+IFsuLi5dDQo+IA0KPiBUaGlzIHNob3VsZCBhbHNvIGJlIGRvY3VtZW50ZWQgYXMgdmFs
aWQgaW4gaW5jbHVkZS9saW51eC9za2J1ZmYuaCwNCj4gdGhvdWdoIEkgZG9uJ3QgdGhpbmsgdGhl
IGZpeCBzaG91bGQgYmUgaGVsZCB1cCBmb3IgdGhhdC4NCj4gDQo+IEJlbi4NClN1cmUsIEkgd2ls
bCBzZW5kIGEgc2VwYXJhdGUgcGF0Y2ggdG8gdXBkYXRlIHRoZSBza2J1ZmYuaCBzaG9ydGx5Lg0K
DQpUaGFua3MsDQp5aQ0KDQo+IA0KPiAtLQ0KPiBCZW4gSHV0Y2hpbmdzLCBTdGFmZiBFbmdpbmVl
ciwgU29sYXJmbGFyZQ0KPiBOb3Qgc3BlYWtpbmcgZm9yIG15IGVtcGxveWVyOyB0aGF0J3MgdGhl
IG1hcmtldGluZyBkZXBhcnRtZW50J3Mgam9iLg0KPiBUaGV5IGFza2VkIHVzIHRvIG5vdGUgdGhh
dCBTb2xhcmZsYXJlIHByb2R1Y3QgbmFtZXMgYXJlIHRyYWRlbWFya2VkLg0KDQo=
