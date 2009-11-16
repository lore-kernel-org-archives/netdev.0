From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 02:58:59 -0800 (PST)
Message-ID: <20091116.025859.78494103.davem@davemloft.net>
References: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
	<20091116.024839.257258321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34232
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752018AbZKPK6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:58:43 -0500
In-Reply-To: <20091116.024839.257258321.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogTW9uLCAxNiBO
b3YgMjAwOSAwMjo0ODozOSAtMDgwMCAoUFNUKQ0KDQo+IEZyb206IENoYW5nbGkgR2FvIDx4aWFv
c3VvQGdtYWlsLmNvbT4NCj4gRGF0ZTogTW9uLCAxNiBOb3YgMjAwOSAxNzo1MzoyOSArMDgwMA0K
PiANCj4+IGFjdF9taXJyZWQ6IG9wdGltaXphdGlvbi4NCj4+IA0KPj4gbW92ZSBjaGVja2luZyBp
ZiBlYWN0aW9uIGlzIHZhbGlkIGluIHRjZl9taXJyZWRfaW5pdCgpDQo+PiANCj4+IFNpZ25lZC1v
ZmYtYnk6IENoYW5nbGkgR2FvIDx4aWFvc3VvQGdtYWlsLmNvbT4NCj4+IFNpZ25lZC1vZmYtYnk6
IEphbWFsIEhhZGkgU2FsaW0gPGhhZGlAY3liZXJ1cy5jYT4NCj4gDQo+IEFsc28gYXBwbGllZCwg
dGhhbmsgeW91Lg0KDQpOZXZlcm1pbmQsIHlvdSdyZSBOT1QgVEVTVElORyB0aGUgcGF0Y2hlcyB5
b3UgYXJlIHBvc3Rpbmc6DQoNCm5ldC9zY2hlZC9hY3RfbWlycmVkLmM6IEluIGZ1bmN0aW9uIOKA
mHRjZl9taXJyZWTigJk6DQpuZXQvc2NoZWQvYWN0X21pcnJlZC5jOjE2ODogZXJyb3I6IGxhYmVs
IOKAmG91dOKAmSB1c2VkIGJ1dCBub3QgZGVmaW5lZA0KbmV0L3NjaGVkL2FjdF9taXJyZWQuYzox
NTg6IHdhcm5pbmc6IHVudXNlZCB2YXJpYWJsZSDigJhlcnLigJkNCm5ldC9zY2hlZC9hY3RfbWly
cmVkLmM6MTU4OiB3YXJuaW5nOiB1bnVzZWQgdmFyaWFibGUg4oCYcmV0dmFs4oCZDQptYWtlWzJd
OiAqKiogW25ldC9zY2hlZC9hY3RfbWlycmVkLm9dIEVycm9yIDENCm1ha2VbMV06ICoqKiBbbmV0
L3NjaGVkXSBFcnJvciAyDQptYWtlWzFdOiAqKiogV2FpdGluZyBmb3IgdW5maW5pc2hlZCBqb2Jz
Li4uLg0KDQpJJ20gdGh1cyByZXZlcnRpbmcgYm90aCBjaGFuZ2VzLg0KDQpEb24ndCBzdWJtaXQg
Y2hhbmdlcyB3aGljaCBhcmUgdW50ZXN0ZWQsIGl0IHdhc3RlcyBteSB0aW1lLg0K
