From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: RE: [PATCH net-next 6/12]bnx2x: Add TPA, Broadcoms HW LRO
Date: Tue, 27 May 2008 11:46:06 -0700
Message-ID: <6B63AF9EF0873F48A86A7F284D05BEE4070FD89C@NT-IRVA-0752.brcm.ad.broadcom.com>
References: <1211897851.6967.79.camel@ubuntu804desktop.localdomain>
 <20080527144752.GI28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	davem@davemloft.net, "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eliezer Tamir" <eliezert@broadcom.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4015 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757688AbYE0TEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 15:04:41 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080527144752.GI28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QmVuIEh1dGNoaW5ncyB3cm90ZToNCj4gPiDvu7/vu7/vu7/vu7/vu79TaWduZWQtb2ZmLWJ5OiBW
bGFkaXNsYXYgWm9sb3Rhcm92IDx2bGFkekBicm9hZGNvbS5jb20+DQo+ID4g77u/77u/U2lnbmVk
LW9mZi1ieTogRWxpZXplciBUYW1pciA8ZWxpZXplcnRAYnJvYWRjb20uY29tPg0KPiANCj4gV2hh
dCdzIHdpdGggdGhlIGJ5dGUgb3JkZXIgbWFya3MgaGVyZT8NClRoYW5rcyBmb3IgcG9pbnRpbmcg
dGhpcyBvdXQuIEl0IHdhcyBub3Qgc2hvd2luZyBvbiBteSBlbWFpbCBjbGllbnQuIElmIG5lZWRl
ZCwgSSB3aWxsIHJlLXN1Ym1pdCB0aGUgcGF0Y2hlcyAtIEkgc2VlIHRoYXQgMS0zIGRpZCBub3Qg
bWFrZSBpdCB5ZXQgYXMgaXMsIHNvIEkgd2lsbCB3YWl0IHRvIHNlZSBpZiByZXN1Ym1pdHRpbmcg
aXMgcmVxdWlyZWQNCj4gDQo+IFsuLi5dDQo+IA0KPiBJdCdzIGltcG9ydGFudCB0aGF0IHBlb3Bs
ZSBhcmUgYWJsZSB0byBzZWUgaG93IHRvIGRpc2FibGUgTFJPLiAgVXNpbmcgYQ0KPiBkaWZmZXJl
bnQgbmFtZSBmb3IgaXQsIGFuZCBubyBtb2R1bGUgcGFyYW1ldGVyIGRlc2NyaXB0aW9uLCByZWFs
bHkgZG9lc24ndA0KPiBoZWxwLg0KVGhlIFRQQSAoVHJhbnNwYXJlbnQgUGFja2V0IEFnZ3JlZ2F0
aW9uKSBpcyBzaW1pbGFyIHRvIExSTyBidXQgaXQgaXMgbm90IHVzaW5nIHRoZSBLZXJuZWwgTFJP
IGJ1dCByYXRoZXIgYSBIVy9GVyBpbXBsZW1lbnRhdGlvbiAtIHNvIHVzaW5nIExSTyBjYW4gYmUg
c29tZXdoYXQgY29uZnVzaW5nLiBPbiB0b3Agb2YgdGhhdCwgVFBBIGlzIGhvdyBtYXJrZXRpbmcg
d2FudHMgdG8gbmFtZSBpdC4uLg0KDQo+IA0KPiBZb3Ugc2hvdWxkIGFsc28gaW1wbGVtZW50IGV0
aHRvb2wgZ2V0X2ZsYWdzIGFuZCBzZXRfZmxhZ3MgbWV0aG9kcyBzbyB0aGF0DQo+IExSTyBjYW4g
YmUgdHVybmVkIG9uIGFuZCBvZmYgbGF0ZXIgKGF0IGxlYXN0IG9uY2UgdGhlIGV0aHRvb2wgY29t
bWFuZCBnZXRzDQo+IHBhdGNoZWQsIGhpbnQgaGludCkuDQpFeGNlbGxlbnQgcG9pbnQgKHNpbmNl
IHdlIGFyZSBwbGFubmluZyB0byBkbyBzbyAtIGl0IGlzIGFuIGV4Y2VsbGVudCBwb2ludCkuIFRo
ZSBwbGFuIGlzIHRvIHN1Ym1pdCBhIG5ldyBwYXRjaCB3aXRoIGV0aHRvb2wgc3VwcG9ydCBhZnRl
ciB0aGlzIG9uZSB3aWxsIGJlIGFjY2VwdGVkIC0gd2UgYWxyZWFkeSBoYWQgdG9vIG1hbnkgY2hh
bmdlcyBwZW5kaW5nDQo+IA0KPiBCZW4uDQo+IA0KVGhhbmtzIGZvciB5b3VyIGNvbW1lbnRzIQ0K
RWlsb24NCg0K

