From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v2] xen-netback: fix fragment detection in checksum
 setup
Date: Fri, 29 Nov 2013 10:32:13 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0196259@AMSPEX01CL01.citrite.net>
References: <1385645032-29848-1-git-send-email-paul.durrant@citrix.com>
 <1385659745.5352.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:30768 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab3K2Kcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 05:32:33 -0500
In-Reply-To: <1385659745.5352.23.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiBTZW50OiAyOCBOb3ZlbWJlciAyMDEzIDE3OjI5
DQo+IFRvOiBQYXVsIER1cnJhbnQNCj4gQ2M6IHhlbi1kZXZlbEBsaXN0cy54ZW4ub3JnOyBuZXRk
ZXZAdmdlci5rZXJuZWwub3JnOyBXZWkgTGl1OyBJYW4gQ2FtcGJlbGw7DQo+IERhdmlkIFZyYWJl
bA0KPiBTdWJqZWN0OiBSZTogW1BBVENIIG5ldCB2Ml0geGVuLW5ldGJhY2s6IGZpeCBmcmFnbWVu
dCBkZXRlY3Rpb24gaW4gY2hlY2tzdW0NCj4gc2V0dXANCj4gDQo+IE9uIFRodSwgMjAxMy0xMS0y
OCBhdCAxMzoyMyArMDAwMCwgUGF1bCBEdXJyYW50IHdyb3RlOg0KPiA+IFRoZSBjb2RlIHRvIGRl
dGVjdCBmcmFnbWVudHMgaW4gY2hlY2tzdW1fc2V0dXAoKSB3YXMgbWlzc2luZyBmb3IgSVB2NA0K
PiBhbmQNCj4gPiB0b28gZWFnZXIgZm9yIElQdjYuIChJdCB0cmFuc3BpcmVzIHRoYXQgV2luZG93
cyBzZWVtcyB0byBzZW5kIElQdjYgcGFja2V0cw0KPiA+IHdpdGggYSBmcmFnbWVudCBoZWFkZXIg
ZXZlbiBpZiB0aGV5IGFyZSBub3QgYSBmcmFnbWVudCAtIGkuZS4gb2Zmc2V0IGlzIHplcm8sDQo+
ID4gYW5kIE0gYml0IGlzIG5vdCBzZXQpLg0KPiANCj4gPiArCS8qIDNmZmYgLT4gZnJhZ21lbnQg
b2Zmc2V0ICE9IDAgT1IgbW9yZSBmcmFnbWVudHMgKi8NCj4gPiArCWlmIChudG9ocyhpcGgtPmZy
YWdfb2ZmKSAmIDB4M2ZmZikNCj4gPiArCQlmcmFnbWVudCA9IHRydWU7DQo+ID4gKw0KPiANCj4g
V2hhdCBhYm91dCB0aGUgbW9yZSBzZWxmIGRvY3VtZW50ZWQgYW5kIGZhc3RlciA6DQo+IA0KPiBp
ZiAoaXBoLT5mcmFnX29mZiAmIGh0b25zKElQX09GRlNFVCB8IElQX01GKSkNCj4gCWZyYWdtZW50
ID0gdHJ1ZTsNCj4gDQoNCk5pY2VyIGRlZmluaXRlbHkuIEknbGwgbmVlZCB0byBhZGQgdGhlIGVx
dWl2YWxlbnQgZGVmIGZvciBJUDZfT0ZGU0VUIHRvIHVzZSB0aGUgc2FtZSBzdHlsZSBvZiB0ZXN0
IHRoZXJlLg0KDQpUaGFua3MsDQoNCiAgUGF1bA0K
