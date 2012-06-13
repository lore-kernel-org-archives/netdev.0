From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 1/9] igb: Add support functions to access thermal
 data.
Date: Wed, 13 Jun 2012 14:53:54 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B626274A6F4B@ORSMSX102.amr.corp.intel.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1339230063-12545-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <1339289333.21665.156.camel@deadeye.wl.decadent.org.uk>
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
Received: from mga14.intel.com ([143.182.124.37]:14551 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754352Ab2FMOx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 10:53:57 -0400
In-Reply-To: <1339289333.21665.156.camel@deadeye.wl.decadent.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pi0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+RnJvbTogQmVuIEh1dGNoaW5ncyBbbWFpbHRv
OmJodXRjaGluZ3NAc29sYXJmbGFyZS5jb21dDQo+U2VudDogU2F0dXJkYXksIEp1bmUgMDksIDIw
MTIgNTo0OSBQTQ0KPlRvOiBLaXJzaGVyLCBKZWZmcmV5IFQNCj5DYzogZGF2ZW1AZGF2ZW1sb2Z0
Lm5ldDsgV3lib3JueSwgQ2Fyb2x5bjsgbmV0ZGV2QHZnZXIua2VybmVsLm9yZzsNCj5nb3Nwb0By
ZWRoYXQuY29tOyBzYXNzbWFubkByZWRoYXQuY29tDQo+U3ViamVjdDogUmU6IFtuZXQtbmV4dCAx
LzldIGlnYjogQWRkIHN1cHBvcnQgZnVuY3Rpb25zIHRvIGFjY2VzcyB0aGVybWFsDQo+ZGF0YS4N
Cj4NCj5PbiBTYXQsIDIwMTItMDYtMDkgYXQgMDE6MjAgLTA3MDAsIEplZmYgS2lyc2hlciB3cm90
ZToNCj4+IEZyb206IENhcm9seW4gV3lib3JueSA8Y2Fyb2x5bi53eWJvcm55QGludGVsLmNvbT4N
Cj4+DQo+PiBTb21lIGkzNTAgZGV2aWNlcyBjb250YWluIHRoZXJtYWwgZGF0YSB0aGF0IHdlIGNh
biBnZXQgdG8gdmlhIGFuIGkyYw0KPj4gaW50ZXJmYWNlLiAgVGhlc2UgZnVuY3Rpb25zIHByb3Zp
ZGUgc3VwcG9ydCB0byBnZXQgYXQgdGhhdCBkYXRhLiAgQQ0KPj4gZm9sbG93aW5nIHBhdGNoIHdp
bGwgZXhwb3J0IHRoaXMgZGF0YS4NCj5bLi4uXQ0KPg0KPldlIGFscmVhZHkgaGF2ZSBhbiBJMkMg
c3Vic3lzdGVtIC0gc28gZG9uJ3QgcmVwbGljYXRlIGkyYy1hbGdvLWJpdCBldGMuDQo+DQo+SXQn
cyBwb3NzaWJsZSB3ZSBhbHNvIGhhdmUgYW4gaHdtb24gZHJpdmVyIGZvciB3aGF0ZXZlciB0ZW1w
ZXJhdHVyZQ0KPnNlbnNvciBpcyBvbiB0aGVzZSBib2FyZHMsIHdoaWNoIHlvdSBjYW4gdGhlbiBw
cm9iZSBieSBjYWxsaW5nDQo+aTJjX25ld19kZXZpY2UoKS4NCg0KSSBhbSBub3Qgc3VyZSB0aGF0
IG91ciBzZW5zb3JzIHdpbGwgYmUgY29tcGF0aWJsZSwgYnV0IEkgd2lsbCByZXNlYXJjaCBpdCB0
byBiZSBzdXJlLiAgSSB3aWxsIGFsc28gdGFrZSBhIGxvb2sgYXQgd2hhdCB3ZSBjYW4gZG8gd2l0
aCB0aGUgaTJjIGludGVyZmFjZSB0aGF0IGFscmVhZHkgZXhpc3RzIGFuZCBtYWtlIHN1cmUgd2Ug
YXJlIG5vdCBkdXBsaWNhdGluZyBhbnkgb2YgaXQuDQoNClRoYW5rcywNCg0KQ2Fyb2x5bg0KDQpD
YXJvbHluIFd5Ym9ybnkNCkxpbnV4IERldmVsb3BtZW50DQpMQU4gQWNjZXNzIERpdmlzaW9uDQpJ
bnRlbCBDb3Jwb3JhdGlvbg0KDQoNCg==
