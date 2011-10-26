From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from
 TIME_WAIT
Date: Wed, 26 Oct 2011 16:01:59 -0400 (EDT)
Message-ID: <20111026.160159.696019885442921932.davem@davemloft.net>
References: <1319611331.18883.13.camel@edumazet-laptop>
	<20111026.155908.1133603039272144196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab1JZUCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 16:02:02 -0400
In-Reply-To: <20111026.155908.1133603039272144196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogV2VkLCAyNiBP
Y3QgMjAxMSAxNTo1OTowOCAtMDQwMCAoRURUKQ0KDQo+IEZyb206IEVyaWMgRHVtYXpldCA8ZXJp
Yy5kdW1hemV0QGdtYWlsLmNvbT4NCj4gRGF0ZTogV2VkLCAyNiBPY3QgMjAxMSAwODo0MjoxMSAr
MDIwMA0KPiANCj4+IGNvbW1pdCA2NmIxM2Q5OWQ5NmEgKGlwdjQ6IHRjcDogZml4IFRPUyB2YWx1
ZSBpbiBBQ0sgbWVzc2FnZXMgc2VudCBmcm9tDQo+PiBUSU1FX1dBSVQpIGZpeGVkIElQdjQgb25s
eS4NCj4+IA0KPj4gVGhpcyBwYXJ0IGlzIGZvciB0aGUgSVB2NiBzaWRlLg0KPj4gDQo+PiBXZSBh
bGlhcyB0d190Y2xhc3MgYW5kIHR3X3RvcywgaWYgc29ja2V0IGZhbWlseSBpcyBJTkVUNi4NCj4+
IA0KPj4gU2lnbmVkLW9mZi1ieTogRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRAZ21haWwuY29t
Pg0KPiANCj4gQXBwbGllZC4NCg0KTmV2ZXJtaW5kLi4uICByZXZlcnRlZC4NCg0KbmV0L2RjY3Av
aXB2Ni5jOiBJbiBmdW5jdGlvbiChZGNjcF92Nl9zZW5kX3Jlc3BvbnNlojoNCm5ldC9kY2NwL2lw
djYuYzoyNzQ6MzogZXJyb3I6IHRvbyBmZXcgYXJndW1lbnRzIHRvIGZ1bmN0aW9uIKFpcDZfeG1p
dKINCmluY2x1ZGUvbmV0L2lwdjYuaDo0ODY6MTQ6IG5vdGU6IGRlY2xhcmVkIGhlcmUNCm5ldC9k
Y2NwL2lwdjYuYzogSW4gZnVuY3Rpb24goWRjY3BfdjZfY3RsX3NlbmRfcmVzZXSiOg0KbmV0L2Rj
Y3AvaXB2Ni5jOjMyOTozOiBlcnJvcjogdG9vIGZldyBhcmd1bWVudHMgdG8gZnVuY3Rpb24goWlw
Nl94bWl0og0KaW5jbHVkZS9uZXQvaXB2Ni5oOjQ4NjoxNDogbm90ZTogZGVjbGFyZWQgaGVyZQ0K
bmV0L2RjY3AvcHJvYmUuYzogSW4gZnVuY3Rpb24goWRjY3Bwcm9iZV9pbml0ojoNCg==
