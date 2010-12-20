From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 20:30:39 +0800
Message-ID: <AANLkTinfMrktz2K99bvSf=VTkEw_V8iXOG1LEG+qWMWG@mail.gmail.com>
References: <4D0E857E.5060302@gmail.com> <4D0E868F.90005@gmail.com>
 <4D0F0D73.2080807@itcare.pl> <AANLkTim1YZd0FgunGKN_YPiLW+uExXajwingUkQeW=a=@mail.gmail.com>
 <1292836097.2800.3.camel@edumazet-laptop> <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
 <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local>
 <1292841671.2800.11.camel@edumazet-laptop> <20101220111141.GC7977@ff.dom.local>
 <20101220115855.GD7977@ff.dom.local> <4D0F471D.8030607@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:61874 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757161Ab0LTMbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 07:31:01 -0500
Received: by fxm18 with SMTP id 18so2958414fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 04:31:00 -0800 (PST)
In-Reply-To: <4D0F471D.8030607@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAxMC8xMi8yMCBQYXdlxYIgU3Rhc3pld3NraSA8cHN0YXN6ZXdza2lAaXRjYXJlLnBsPjoKPiBX
aXRoIHRoaXMgcGF0Y2g6Cj4KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVf
bWFpbi5jIGIvZHJpdmVycy9uZXQvaXhnYmUvaXhnYmVfbWFpbi5jCj4gaW5kZXggY2E5MDM2ZC4u
NjAyY2QzMiAxMDA2NDQKPiAtLS0gYS9kcml2ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmMKPiAr
KysgYi9kcml2ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmMKPiBAQCAtNjA5Niw2ICs2MDk2LDE1
IEBAIHN0YXRpYyBpbnQgaXhnYmVfdHNvKHN0cnVjdCBpeGdiZV9hZGFwdGVyICphZGFwdGVyLAo+
IMKgIMKgIMKgIMKgdTMyIG1zc19sNGxlbl9pZHgsIGw0bGVuOwo+Cj4gwqAgwqAgwqAgwqBpZiAo
c2tiX2lzX2dzbyhza2IpKSB7Cj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCBpZiAoc2tiX3NoYXJl
ZChza2IpKSB7Cj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBzdHJ1Y3Qgc2tf
YnVmZiAqbnNrYjsKPiArCj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBuc2ti
ID0gc2tiX2Nsb25lKHNrYiwgR0ZQX0FUT01JQyk7Cj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCBpZiAoIW5za2IpCj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCByZXR1cm4gLUVOT01FTTsKPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIGtmcmVlX3NrYihza2IpOwo+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgc2tiID0gbnNrYjsKPiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIH0KPiDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoGlmIChza2JfaGVhZGVyX2Nsb25lZChza2IpKSB7Cj4gwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBlcnIgPSBwc2tiX2V4cGFuZF9oZWFkKHNrYiwgMCwgMCwg
R0ZQX0FUT01JQyk7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBpZiAoZXJy
KQo+Cj4KPiBJIGhhdmUgdGhlIHNhbWUgcGFuaWMgYXMgd2l0aG91dC4KPgo+IFRoaXMgcGF0Y2gg
d2FzIGFkZGVkIHRvIGNsZWFuIDIuNi4zNy1yYzYgLSB3aXRob3V0IHByZXZpb3VzIHBhdGNoIGZv
cgo+IHNjaF9nZW5lcmljLmgKPgo+IEF0dGFjaGVkIGltYWdlIHdpdGgga2VybmVsIHBhbmljLgo+
Cj4KClNpZ2guIFdlIGhhdmUgdG8gcmV2ZXJ0IG15IHBhdGNoIGZpcnN0LiA6KAoKLS0gClJlZ2Fy
ZHMsCkNoYW5nbGkgR2FvKHhpYW9zdW9AZ21haWwuY29tKQo=
