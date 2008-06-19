From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] bnx2: Optimize fast-path tx and rx work.
Date: Thu, 19 Jun 2008 16:41:21 -0700 (PDT)
Message-ID: <20080619.164121.98886728.davem@davemloft.net>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
	<1213835132-5698-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48786
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754169AbYFSXlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 19:41:21 -0400
In-Reply-To: <1213835132-5698-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogIk1pY2hhZWwgQ2hhbiIgPG1jaGFuQGJyb2FkY29tLmNvbT4NCkRhdGU6IFdlZCwgMTgg
SnVuIDIwMDggMTc6MjU6MjcgLTA3MDANCg0KPiBBZGQgaHdfdHhfY29uc19wdHIgYW5kIGh3X3J4
X2NvbnNfcHRyIHRvIHNwZWVkIHVwIHRoZSByZXRyZWl2YWwgb2YNCj4gdGhlIHR4IGFuZCByeCBj
b25zdW1lciBpbmRleCwgc2luY2UgdGhlIE1TSS1YIGFuZCBkZWZhdWx0IHN0YXR1cw0KPiBibG9j
a3MgaGF2ZSBkaWZmZXJlbnQgc3RydWN0dXJlcy4NCj4gDQo+IENvbWJpbmUgc3RhdHVzX2JsayBh
bmQgc3RhdHVzX2Jsa19tc2l4IGludG8gYSB1bmlvbi4gIFdlJ2xsIG9ubHkgdXNlDQo+IG9uZSB0
eXBlIG9mIHN0YXR1cyBibG9jayBmb3IgZWFjaCB2ZWN0b3IuDQo+IA0KPiBTZXBhcmF0ZSB0aGUg
Y29kZSB0byBkZXRlY3QgbW9yZSByeCBhbmQgdHggd29yayBmcm9tIHRoZSBjb2RlIHRvDQo+IGRl
dGVjdCBsaW5rIHJlbGF0ZWQgd29yay4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IE1pY2hhZWwgQ2hh
biA8bWNoYW5AYnJvYWRjb20uY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBCZW5qYW1pbiBMaSA8YmVu
bGlAYnJvYWRjb20uY29tPg0KDQpUaGlzIGFkZHMgYSBuZXcgd2FybmluZzoNCg0KZHJpdmVycy9u
ZXQvYm54Mi5jOiBJbiBmdW5jdGlvbiDigJhibngyX3BvbGxfbGlua+KAmToNCmRyaXZlcnMvbmV0
L2JueDIuYzozMTY0OiB3YXJuaW5nOiBubyByZXR1cm4gc3RhdGVtZW50IGluIGZ1bmN0aW9uIHJl
dHVybmluZyBub24tdm9pZA0KDQpTbyBJIGNoYW5nZWQgYm54Ml9wb2xsX2xpbmsoKSB0byByZXR1
cm4gJ3ZvaWQnIHdoZW4NCmNoZWNraW5nIHRoaXMgaW4uDQo=
