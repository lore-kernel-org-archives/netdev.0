From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add sk_mark route lookup support for IPv4 listening
 sockets, and for IPv4 multicast forwarding
Date: Wed, 07 Oct 2009 22:39:28 -0700 (PDT)
Message-ID: <20091007.223928.34412707.davem@davemloft.net>
References: <200910071559.56526.atis@mikrotik.com>
	<20091007.135627.96995518.davem@davemloft.net>
	<55a4f86e0910071703i4735f1aan1ddba81eec7eef19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: atis@mikrotik.com, netdev@vger.kernel.org, panther@balabit.hu,
	eric.dumazet@gmail.com, brian.haley@hp.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44502
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752968AbZJHFjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 01:39:33 -0400
In-Reply-To: <55a4f86e0910071703i4735f1aan1ddba81eec7eef19@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTWFjaWVqIMW7ZW5jenlrb3dza2kgPHplbmN6eWtvd3NraUBnbWFpbC5jb20+DQpEYXRl
OiBXZWQsIDcgT2N0IDIwMDkgMTc6MDM6MzAgLTA3MDANCg0KPiBTaG91bGQgd3JhcHBpbmcgYSBw
YWNrZXQgaW50byBhIHR1bm5lbCBjbGVhciB0aGUgbWFyaz8NCj4gU2hvdWxkIHBlcmhhcHMgdGhl
IG1hcmsgYmUgYSBwYXJhbWV0ZXIgb2YgdGhlIHR1bm5lbCAobGlrZSB0dGwgb3IgcW9zLA0KPiBj
YW4gYmUgc2V0IG9yIGNhbiBiZSBpbmhlcml0ZWQpPw0KDQpUaGF0J3MgdGhlIGJpZyBxdWVzdGlv
bi4NCg0KSXQgbWF5IGJlIHRoYXQgdGhlIG9ubHkgbG9naWNhbCB0aGluZyB3ZSBjYW4gZG8gaXMg
b25seSBhcHBseQ0KdGhlIHNvY2tldCBtYXJrIHRvIHRoZSB0b3AtbGV2ZWwgcGF0aCBhbmQgdGhh
dCdzIHdoYXQgaGFwcGVucw0Kbm93Lg0KDQpCZWNhdXNlIHdlIHJlYWxseSBkb24ndCBoYXZlIGFu
eSByZWFzb25hYmxlIHdheSB0byBsZXQgdGhlIHVzZXINCmNvbnRyb2wgd2hlcmUgaXQgYXBwbGll
cy4gIFdlIGhhdmUgbm8gd2F5IGZvciBpdCB0byBzYXkgImRvbid0DQphcHBseSB0aGUgbWFyayB0
byB0aGUgdG9wLWxldmVsIHBhdGgsIGJ1dCBkbyBhcHBseSBpdCB0byB0aGUNCm11bHRpY2FzdCB0
dW5uZWwnIG9yIHNvbWV0aGluZyBsaWtlIHRoYXQuDQoNClNvLCB0byBiZSBob25lc3QsIEknZCBz
YXkgd2Ugc2hvdWxkIHNraXAgdGhlc2Ugc2tiLT5tYXJrIGNhc2VzDQpmb3Igbm93Lg0K
