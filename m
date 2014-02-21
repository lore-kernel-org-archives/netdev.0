From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH V4 net-next 1/5] xen-netback: Factor queue-specific data
 into queue struct.
Date: Fri, 21 Feb 2014 12:24:52 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD0255399@AMSPEX01CL01.citrite.net>
References: <1392659880-2538-1-git-send-email-andrew.bennieston@citrix.com>
 <1392659880-2538-2-git-send-email-andrew.bennieston@citrix.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD02552E8@AMSPEX01CL01.citrite.net>
 <53074518.5010506@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>
To: Andrew Bennieston <andrew.bennieston@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:27429 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaBUMYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 07:24:54 -0500
In-Reply-To: <53074518.5010506@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KW3NuaXBdDQo+ID4NCj4gPiBBbnkgcmVhc29u
IHdoeSB0aGlzIGlzIG5vdCBpbiB4ZW52aWZfc3RhdHM/IElmICBpdCB3ZXJlIHRoZXJlIHRoZW4g
aXQgd291bGQNCj4gbm90IG5lZWQgdG8gYmUgYXRvbWljLg0KPiBUaGUgZXhwZWN0YXRpb24gd2Fz
IHRoYXQgaXQgd291bGRuJ3QgYmUgdXNlZCB2ZXJ5IG9mdGVuLCBzbyBhbiBhdG9taWMNCj4gb3Au
IGhlcmUgd291bGRuJ3QgaHVydC4gSSBjYW4gbW92ZSBpdCB0byB4ZW52aWZfc3RhdHMgaWYgeW91
J2QgcHJlZmVyLA0KPiB0aG91Z2guIEkgdGhpbmsgdGhlIHVzZSBvZiBhbiBhdG9taWMgcHJlLWRh
dGVkIHRoZSB4ZW52aWZfc3RhdHMgc3RydWN0LA0KPiBzbyBtYXliZSBpdCBtYWtlcyBzZW5zZSB0
byBtb3ZlIGl0IHRoZXJlIG5vdy4NCj4gDQoNCkkgdGhpbmsgc28uIFNlZW1zIG9kZCB0byBsZWF2
ZSBpdCBvdXQgb24gaXRzIG93bi4NCg0KICBQYXVsDQo=
