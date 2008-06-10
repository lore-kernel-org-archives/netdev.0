From: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 11 Jun 2008 01:26:44 +0200
Message-ID: <a01a16b50806101626i2942ebam462410ad26050829@mail.gmail.com>
References: <20080526115628.GA31316@elte.hu>
	 <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
	 <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
	 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
	 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
	 <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
	 <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
	 <Pine.LNX.4.64.0806041802360.2580@wrl-59.cs.helsinki.fi>
	 <a01a16b50806060232u1eff3867u24fecc539fda1d14@mail.gmail.com>
	 <Pine.LNX.4.64.0806091422180.16829@wrl-59.cs.helsinki.fi>
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
Received: from rv-out-0506.google.com ([209.85.198.231]:54320 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbYFJX0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 19:26:45 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1151282rvb.1
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2008 16:26:44 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0806091422180.16829@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAwOC82LzkgSWxwbyBKw6RydmluZW4gPGlscG8uamFydmluZW5AaGVsc2lua2kuZmk+Ogo+IE9u
IEZyaSwgNiBKdW4gMjAwOCwgSMOla29uIEzDuHZkYWwgd3JvdGU6Cj4+IEkgaGF2ZSBub3cgc2V0
IHVwIGEgc2VydmVyIG9uIG15IG1hY2hpbmUgYW5kIG1hZGUgYWxsIGxvZ3MgYXZhaWxhYmxlLgo+
PiBJIHdpbGwgZm9sbG93IHVwIHdpdGggdGhlIGFkcmVzcyBpbiBwcml2YXRlIGVtYWlsIHRvIHRo
b3NlIHRoYXQgYWxyZWFkeQo+PiBoYXZlIHBvc3RlZCBpbiB0aGlzIHRocmVhZC4gRm9yIG90aGVy
cywgcGxlYXNlIGFzayB0byByZWNlaXZlIGl0Lgo+Cj4gQ2FuIHlvdSBwbGVhc2UgZXhwbGFpbiB0
aGlzOgo+Cj4gaWpqYXJ2aW5Ad3JsLTU5On4vdG1wJCBidW56aXAyIC10IGNvcHl0ZXN0MDAzLmNh
cHR1cmUuYnoyCj4gYnVuemlwMjogY29weXRlc3QwMDMuY2FwdHVyZS5iejI6IGRhdGEgaW50ZWdy
aXR5IChDUkMpIGVycm9yIGluIGRhdGEKPgo+IFlvdSBjYW4gdXNlIHRoZSBgYnppcDJyZWNvdmVy
JyBwcm9ncmFtIHRvIGF0dGVtcHQgdG8gcmVjb3Zlcgo+IGRhdGEgZnJvbSB1bmRhbWFnZWQgc2Vj
dGlvbnMgb2YgY29ycnVwdGVkIGZpbGVzLgo+Cj4gaWpqYXJ2aW5Ad3JsLTU5On4vdG1wJCBscyAt
YWwgY29weXRlc3QwMDMuY2FwdHVyZS5iejIKPiAtcnctci0tLS0tIDEgaWpqYXJ2aW4gdGtvbCAy
NzU0NDE2MjAgIDkuIGtlc8ODwqTDgiDDgiAgMTY6MzkKPiBjb3B5dGVzdDAwMy5jYXB0dXJlLmJ6
Mgo+IGlqamFydmluQHdybC01OTp+L3RtcCQgbWQ1c3VtIGNvcHl0ZXN0MDAzLmNhcHR1cmUuYnoy
Cj4gNGJiZjgwMWNmMWZiZDUyMzk5MzIyYjA4OGMxYTIwNTggIGNvcHl0ZXN0MDAzLmNhcHR1cmUu
YnoyCj4gaWpqYXJ2aW5Ad3JsLTU5On4vdG1wJAo+Cj4gLi4uYWxzbyB0aGUgb25lIGZyb20gYWxs
ZmlsZXMuemlwIGlzIHNpbWlsYXJpbHkgZGFtYWdlZC4KPgo+IC4uLklmIHlvdSBkb24ndCBoYXZl
IGFuIGV4cGxhbmF0aW9uLCB0aGVtIGl0IG1pZ2h0IGJlIHRpbWUgdG8gY2hlY2sKPiB5b3VyIGhh
cmR3YXJlLi4uLgoKSSBkbyBub3QgaGF2ZSBhbnkgZ29vZCBleHBsYW5hdGlvbiAoYmFkIG1lbW9y
eT8pLiBXaGVuIGNoZWNraW5nIHRoZQpjb3B5dGVzdDAwMy5jYXB0dXJlLmJ6MiBmaWxlIGluIHRo
ZSBodHRwIHNlcnZlciBzdG9yYWdlIGRpcmVjdG9yeQpJIGdldCB0aGUgc2FtZSByZXN1bHRzIGFz
IHlvdS4gSG93ZXZlciBJIGFsc28gaGF2ZSB0aGUgb3JpZ2luYWwgZmlsZQpzdG9yZWQgc3RpbGwg
YW5kIGNvbXBhcmluZyB0aGVtIHdpdGggY21wIC1sIGdpdmVzCiAyMDU1ODY1NiAxMjQgMTA0CnNv
IG9idmlvdXNseSBhIGJpdCBoYXMgYmVlbiBmbGlwcGVkLiBJIGhhdmUgbm93IHJlcGxhY2VkIHRo
ZQplcnJvbmVvdXMgZmlsZSB3aXRoIGEgZ29vZCBjb3B5LCBzbyB5b3Ugc2hvdWxkIGJlIGFibGUg
dG8gZG93bmxvYWQgYWdhaW4uCgpCUiBIw6Vrb24gTMO4dmRhbAoKQnR3LCBJIGdvdCBhICJ0cmFk
aXRpb25hbCIgaGFuZyBub3cgb24gbXkgZmlyc3QgYXR0ZW1wdCB0byBjb3B5CmNvcHl0ZXN0MDAz
LmNhcHR1cmUuYnoyIGZyb20gb2xkX3BjIHRvIG5ld19wYyBqdXN0IHVzaW5nIHNjcC4K
