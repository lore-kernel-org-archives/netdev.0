From: David Miller <davem@davemloft.net>
Subject: Re: cls_cgroup: Store classid in struct sock
Date: Sun, 23 May 2010 23:55:57 -0700 (PDT)
Message-ID: <20100523.235557.165343768.davem@davemloft.net>
References: <20100521164054.GB29521@hmsreliant.think-freely.org>
	<20100522014957.GA8779@gondor.apana.org.au>
	<20100523.234441.66200781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753654Ab0EXGzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:55:47 -0400
In-Reply-To: <20100523.234441.66200781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogU3VuLCAyMyBN
YXkgMjAxMCAyMzo0NDo0MSAtMDcwMCAoUERUKQ0KDQo+IEZyb206IEhlcmJlcnQgWHUgPGhlcmJl
cnRAZ29uZG9yLmFwYW5hLm9yZy5hdT4NCj4gRGF0ZTogU2F0LCAyMiBNYXkgMjAxMCAxMTo0OTo1
NyArMTAwMA0KPiANCj4+IE9uIEZyaSwgTWF5IDIxLCAyMDEwIGF0IDEyOjQwOjU0UE0gLTA0MDAs
IE5laWwgSG9ybWFuIHdyb3RlOg0KPj4+IA0KPj4+IFRoZXJlIG1heSBhbHNvIGJlIGFuIGlzc3Vl
IHdpdGggdGhlIHNldHRpbmcgb2YgdGhlIGNsYXNzaWQgKHBvc3NpYmxlIHVzZSBvZiB0aGUNCj4+
PiB3cm9uZyBzdWJzeXMgaWQgdmFsdWUgd2hlbiBncmFiYmluZyBvdXIgY2dyb3VwX3N1YnN5c19z
dGF0ZSksIGJ1dCBJJ20gY2hlY2tpbmcNCj4+PiBvbiB0aGF0IG5vdy4NCj4+IA0KPj4gQWN0dWFs
bHksIEkgdGhpbmsgaXQncyBiZWNhdXNlIG15IHBhdGNoIG1pc3Rvb2sgQ09ORklHX0NHUk9VUA0K
Pj4gZm9yIENPTkZJR19DR1JPVVBTLg0KPj4gDQo+PiBIZXJlIGlzIGEgZml4ZWQgdmVyc2lvbiAo
YWxzbyBpbmNsdWRlcyBhIGJ1aWxkIGZpeCBvbiBzay0+Y2xhc3NpZCkuDQo+PiANCj4+IGNsc19j
Z3JvdXA6IFN0b3JlIGNsYXNzaWQgaW4gc3RydWN0IHNvY2sNCj4gDQo+IEJUVyBJIG1hZGUgc3Vy
ZSB0byBhcHBseSB0aGlzIHZlcnNpb24uDQoNCkFjdHVhbGx5IEkgaGFkIHRvIHJldmVydCwgZG9l
c24ndCBidWlsZDoNCg0KICBDQyBbTV0gIGRyaXZlcnMvbmV0L3BwcG9lLm8NCkluIGZpbGUgaW5j
bHVkZWQgZnJvbSBuZXQvc29ja2V0LmM6OTc6DQppbmNsdWRlL25ldC9jbHNfY2dyb3VwLmg6MjI6
IGVycm9yOiBmaWVsZCChY3NzoiBoYXMgaW5jb21wbGV0ZSB0eXBlDQptYWtlWzFdOiAqKiogW25l
dC9zb2NrZXQub10gRXJyb3IgMQ0KbWFrZTogKioqIFtuZXRdIEVycm9yIDINCm1ha2U6ICoqKiBX
YWl0aW5nIGZvciB1bmZpbmlzaGVkIGpvYnMuLi4uDQoNClByb2JhYmx5IHlvdSBvbmx5IHRlc3Rl
ZCB0aGUgYnVpbGQgd2l0aCBjZ3JvdXBzIGVuYWJsZWQ/DQo=
