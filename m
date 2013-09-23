From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next v2 2/2] xen-netback: handle
 frontends that fail to transition through Closing
Date: Mon, 23 Sep 2013 08:59:57 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD01103F3@AMSPEX01CL01.citrite.net>
References: <1379685460-25032-1-git-send-email-paul.durrant@citrix.com>
 <1379685460-25032-3-git-send-email-paul.durrant@citrix.com>
 <20130920161431.GA19095@mail.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Bastian Blank <bastian@waldi.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23949 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab3IWJAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 05:00:00 -0400
In-Reply-To: <20130920161431.GA19095@mail.waldi.eu.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBCYXN0aWFuIEJsYW5rIFttYWls
dG86YmFzdGlhbkB3YWxkaS5ldS5vcmddDQo+IFNlbnQ6IDIwIFNlcHRlbWJlciAyMDEzIDE3OjE1
DQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IHhlbi1k
ZXZlbEBsaXN0cy54ZW4ub3JnOyBXZWkgTGl1OyBEYXZpZCBWcmFiZWw7DQo+IElhbiBDYW1wYmVs
bA0KPiBTdWJqZWN0OiBSZTogW1hlbi1kZXZlbF0gW1BBVENIIG5ldC1uZXh0IHYyIDIvMl0geGVu
LW5ldGJhY2s6IGhhbmRsZQ0KPiBmcm9udGVuZHMgdGhhdCBmYWlsIHRvIHRyYW5zaXRpb24gdGhy
b3VnaCBDbG9zaW5nDQo+IA0KPiBPbiBGcmksIFNlcCAyMCwgMjAxMyBhdCAwMjo1Nzo0MFBNICsw
MTAwLCBQYXVsIER1cnJhbnQgd3JvdGU6DQo+ID4gU29tZSBvbGQgV2luZG93cyBmcm9udGVuZHMg
ZmFpbCB0byB0cmFuc2l0aW9uIHRocm91Z2ggdGhlIHhlbmJ1cyBDbG9zaW5nDQo+ID4gc3RhdGUg
YW5kIG1vdmUgZGlyZWN0bHkgZnJvbSBDb25uZWN0ZWQgdG8gQ2xvc2VkLiBIYW5kbGUgdGhpcyBj
YXNlDQo+IHByb3Blcmx5Lg0KPiANCj4gV2hhdCBoYXBwZW5zIGluIHRoaXMgY2FzZT8gQXJlIHRo
ZXJlIG90aGVyIHN0YXRlIGNoYW5nZXMgdGhhdCB3aWxsIGRvDQo+IHVud2FudGVkIHRoaW5ncz8N
Cj4gDQoNCkhtbSwgbm93IHlvdSBtZW50aW9uIGl0IEkgc3VzcGVjdCBhIHRyYW5zaXRpb24gZGly
ZWN0bHkgdG8gYW4gdW5rbm93biBzdGF0ZSBtYXkgYWxzbyBub3QgZG8gdGhlIHJpZ2h0IHRoaW5n
LiBQZXJoYXBzIGl0IHdvdWxkIGJlIGJldHRlciB0byBnbyBzdHJhaWdodCB0byBhIG1vcmUgcm9i
dXN0IHN0YXRlIG1vZGVsIGFzIHN1Z2dlc3RlZCBieSBEYXZpZCBWcmFiZWwuDQoNCiAgUGF1bA0K
