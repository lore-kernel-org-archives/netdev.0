From: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Thu, 19 Jun 2008 02:30:08 +0200
Message-ID: <a01a16b50806181730gec225fbgf2057a727089c997@mail.gmail.com>
References: <20080526115628.GA31316@elte.hu>
	 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
	 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
	 <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
	 <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
	 <Pine.LNX.4.64.0806041802360.2580@wrl-59.cs.helsinki.fi>
	 <a01a16b50806060232u1eff3867u24fecc539fda1d14@mail.gmail.com>
	 <Pine.LNX.4.64.0806091422180.16829@wrl-59.cs.helsinki.fi>
	 <a01a16b50806101626i2942ebam462410ad26050829@mail.gmail.com>
	 <Pine.LNX.4.64.0806111636330.16829@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, "Ingo Molnar" <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "=?UTF-8?Q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:18716 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757629AbYFSAaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 20:30:09 -0400
Received: by rv-out-0506.google.com with SMTP id k40so4897611rvb.1
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 17:30:09 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0806111636330.16829@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAwOC82LzExIElscG8gSsOkcnZpbmVuIDxpbHBvLmphcnZpbmVuQGhlbHNpbmtpLmZpPjoKPiBP
biBXZWQsIDExIEp1biAyMDA4LCBIw6Vrb24gTMO4dmRhbCB3cm90ZToKPj4gSSBkbyBub3QgaGF2
ZSBhbnkgZ29vZCBleHBsYW5hdGlvbiAoYmFkIG1lbW9yeT8pLiBXaGVuIGNoZWNraW5nIHRoZQo+
PiBjb3B5dGVzdDAwMy5jYXB0dXJlLmJ6MiBmaWxlIGluIHRoZSBodHRwIHNlcnZlciBzdG9yYWdl
IGRpcmVjdG9yeQo+PiBJIGdldCB0aGUgc2FtZSByZXN1bHRzIGFzIHlvdS4gSG93ZXZlciBJIGFs
c28gaGF2ZSB0aGUgb3JpZ2luYWwgZmlsZQo+PiBzdG9yZWQgc3RpbGwgYW5kIGNvbXBhcmluZyB0
aGVtIHdpdGggY21wIC1sIGdpdmVzCj4+ICAyMDU1ODY1NiAxMjQgMTA0Cj4+IHNvIG9idmlvdXNs
eSBhIGJpdCBoYXMgYmVlbiBmbGlwcGVkLgo+Cj4gLi4uWWVhaCwgd2hpY2ggaXMgYSBiYWQgdGhp
bmcgYmVjYXVzZSBub3cgd2UgZG9uJ3Qga25vdyBpZiB0aGF0IHNhbWUgZXJyb3IKPiBjYXVzZXMg
dGhlIFRDUCBzdG9wcyB0b28uCj4KPj4gSSBoYXZlIG5vdyByZXBsYWNlZCB0aGUgZXJyb25lb3Vz
IGZpbGUgd2l0aCBhIGdvb2QgY29weSwgc28geW91IHNob3VsZAo+PiBiZSBhYmxlIHRvIGRvd25s
b2FkIGFnYWluLgo+Cj4gSSdsbCBoYXZlIGEgbG9vayBpZiB0aGVyZSdzIHNvbWUgY29tbW9uIGRl
bm9taW5hdG9yIGJ1dCB0aGlzIHdob2xlIGlzc3VlCj4gbWlnaHQgd2VsbCBiZSBkdWUgdG8gaHcg
ZmFpbHVyZS4KPgoKSGkuIEkgdGVzdGVkIHRoZSBvbGQgcGMgd2l0aCBtZW10ZXN0ODYgYW5kIG1l
bXRlc3Q4NisgZm9yIDE2IGFuZCA1MApob3VycyB3aXRob3V0IGFueSBlcnJvcnMgZGV0ZWN0ZWQs
IHNvIGFwcGFyZW50bHkgdGhlIHJhbSBpcyBvay4KCkkgbm93IGp1c3QgZGlkIGFub3RoZXIgdGVz
dCBmcm9tIGEgZnJlc2hsZXkgYm9vdGVkIG9sZCBwYywgc3RhbmRpbmcKaWRsZSBmb3IgYXJvdW5k
IDIgaG91cnMgYmVmb3JlIEkgc3RhcnRlZCB0aGUgdGVzdGluZyAobm8gbmV0d29yayBhY3Rpdml0
eQpiZWZvcmUgSSBwbHVnZ2VkIGluIHRoZSBjYWJsZSBqdXN0IGJlZm9yZSBzdGFydGluZyB0ZXN0
aW5nKS4KClRoZSBjb3B5aW5nIGZhaWxlZCBhZnRlciBqdXN0IDIuNjJHQiwgc28gdGhlIGxvZ3Mg
YXJlIHNob3J0IGFuZApuaWNlLiBTdG9yZWQgb24gc2FtZSBzZXJ2ZXIgYXMgZWFybGllciwgbmV3
IDIwMDgtMDYtMTkgZGlyZWN0b3J5LiBPbmUKdGhpbmcgSSBub3RpY2VkIGluIHRoZSBkbWVzZyBv
dXRwdXQgb24gdGhlIG9sZCBwYyB3YXMgdGhlIGZvbGxvd2luZzoKCkJVRzogdW5hYmxlIHRvIGhh
bmRsZSBrZXJuZWwgcGFnaW5nIHJlcXVlc3QgYXQgdmlydHVhbCBhZGRyZXNzIGZmZmYzY2ZmCnBy
aW50aW5nIGVpcDogZmZmZjNjZmYgKnBkZSA9IDAwNzkzMDY3ICpwdGUgPSAwMDAwMDAwMApPb3Bz
OiAwMDAwIFsjMV0gUFJFRU1QVApNb2R1bGVzIGxpbmtlZCBpbjogLi4uClBpZDogMTgxMDMsIGNv
bW06IHNzaGQgTm90IHRhaW50ZWQgKDIuNi4yNC1nYWZkNTY0YTggIzQpCi4uLgpDYWxsIFRyYWNl
OgogWzxmOGM0NWIzOT5dIG5mX2Nvbm50cmFja19maW5kX2dldCsweDM2LzB4M2EgW25mX2Nvbm50
cmFja10KIFs8ZjhjNDYzNzk+XSBuZl9jb25udHJhY2tfaW4rMHgxMzUvMHgzZTggW25mX2Nvbm50
cmFja10KIFs8YzA0MjNjNWQ+XSBsb2NhbF9iaF9kaXNhYmxlKzB4YS8weGIKIFs8YzA2MjZkNTQ+
XSBfcmVhZF9sb2NrX2JoKzB4MTIvMHgxYQouLi4KCkJSIEjDpWtvbiBMw7h2ZGFsCg==
