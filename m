From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 v6 08/12] net-caif: add CAIF socket
 implementation
Date: Wed, 17 Mar 2010 12:04:11 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C1057916954ED6B0@EXDCVYMBSTM005.EQ1STM.local>
References: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-2-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-3-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-4-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-5-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-6-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-7-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-8-git-send-email-sjur.brandeland@stericsson.com>
	 <1267445559-1911-9-git-send-email-sjur.brandeland@stericsson.com>
	 <1268690031.2700.9.camel@localhost.localdomain>
	 <61D8D34BB13CFE408D154529C120E079033D51A2@eseldmw101.eemea.ericsson.se>
 <1268805781.2700.46.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Daniel MARTENSSON <daniel.martensson@stericsson.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"stefano.babic@babic.homelinux.org"
	<stefano.babic@babic.homelinux.org>,
	"randy.dunlap@oracle.com" <randy.dunlap@oracle.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:49528 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754406Ab0CQL1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 07:27:18 -0400
In-Reply-To: <1268805781.2700.46.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgTWFyY2VsLA0KPj4gPj4gKwkgKiBUaGUgc29jay0+dHlwZSBzcGVjaWZpZXMgdGhlIHNvY2tl
dCB0eXBlIHRvIHVzZS4gVGhlIENBSUYNCj4+ID4+IHNvY2tldCBpcyArCSAqIGEgcGFja2V0IHN0
cmVhbSBpbiB0aGUgc2VuY2UgdGhhdCBpdCBpcyBwYWNrZXQgYmFzZWQuDQo+PiA+PiArCSAqIENB
SUYgdHJ1c3RzIHRoZSByZWxpYWJpbGl0eSBvZiB0aGUgbGluaywgbm8gcmVzZW5kaW5nIGlzDQo+
PiA+PiBpbXBsZW1lbnRlZC4gKwkgKi8gKwlpZiAoc29jay0+dHlwZSAhPSBTT0NLX1NFUVBBQ0tF
VCkNCj4+ID4+ICsJCXJldHVybiAtRVNPQ0tUTk9TVVBQT1JUOw0KPj4gPiANCj4+ID4gd2UgY2Ft
ZSB0byBhbiBpbnRlcmVzdGluZyBkZXRhaWwgaGVyZSB3aGVuIHRlc3Rpbmcgd2l0aCBhIFNURSBt
b2RlbS4NCj4+ID4gV2h5IGlzIHRoaXMgU0VRUEFDS0VUIGFuZCBub3QgYSBTVFJFQU0uDQo+PiAN
Cj4+IFRoZSByZWFzb24gaXMgdGhhdCBDQUlGIHByb3ZpZGVzIGRpZmZlcmVudCBzZXJ2aWNlcyBu
b3QganVzdCBBVCwNCj4+IGFuZCBzb21lIG9mIHRoZW0gYXJlIHJlYWxseSBwYWNrZXQgb3JpZW50
ZWQgc3VjaCBhcyBVdGlsaXR5IGxpbmtzIGFuZA0KPj4gVmlkZW8uIEl0IHdvdWxkIG5vdCBiZSBy
aWdodCB0byBwcm92aWRlIGEgc3RyZWFtIGJhc2VkIHNvbHV0aW9uIGluIHRoaXMgY2FzZS4NCj4+
IA0KPj4gPiBFc3BlY2lhbGx5IHdpdGggdGhlIEFUDQo+PiA+IGNvbW1hbmQgY2hhbm5lbHMgaXQg
aXMga2luZGEgd2VpcmQgdGhhdCB5b3UgaGF2ZSBhbiBNVFUuIFRoZSBBVA0KPj4gPiBzcGVjaWZp
Y2F0aW9uIGRvZXNuJ3QgcmVhbGx5IGhhdmUgYW55IGRlZmluZWQgYmVoYXZpb3Igd2hlbiB1c2lu
ZyBhDQo+PiA+IHNlcXVlbnRpYWwgcGFja2V0IHRyYW5zcG9ydC4gSXQgaXMgbW9yZSBhIHN0cmVh
bSBiYXNlZCBzb2NrZXQuDQo+PiANCj4+IFllcyBJIHNlZSB5b3VyIHBvaW50LiBJbiBvcmRlciB0
byBsaW1pdCB0aGUgZWZmb3J0IGFuZCBzaW1wbGlmeQ0KPj4gY2FpZl9zb2NrZXQgd2UgZW5kZWQg
dXAgaW1wbGVtZW50aW5nIG9ubHkgU0VRUEFDS0VULiANCj4NCj5JIHRoaW5rIHdlIG5lZWQgdG8g
c3BsaXQgdGhpcy4gVXNlIFNFUVBBQ0tFVCBmb3IgcGFja2V0IGJhc2VkIHNlcnZpY2VzDQo+YW5k
IGhhdmUgU1RSRUFNIGZvciBBVCBjb21tYW5kIGNoYW5uZWwuDQo+U28gd2hpbGUgdGhpcyBtaWdo
dCBjYXVzZSBpbnRlcm5hbGx5IHNvbWUgbW9yZSBjb2RlLiBJdCB3b3VsZCB0YWtlIGF3YXkNCj50
aGUgY29tcGxleGl0eSBmcm9tIHVzZXJzcGFjZSB0byB0dXJuIGl0IGludG8gYSBzdHJlYW0uIEFu
ZCB0aGF0IGlzIHdoYXQNCj50aGUgdXNlcnNwYWNlIGlzIGV4cGVjdGluZy4NCg0KT2sgTWFyY2Vs
LCBJJ2xsIGxvb2sgaW50byBzdXBwb3J0aW5nIGJvdGggU1RSRUFNIGFuZCBTRVFQQUNLRVQuDQpC
Ui9TanVyDQo=
