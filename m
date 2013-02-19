From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] ipv6: rt6_update_expires() seems racy
Date: Tue, 19 Feb 2013 06:30:32 -0500
Message-ID: <cmysjd5kttdebnlrt28jldw3.1361273432405@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>, Jiri Bohac <jbohac@suse.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53558 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756613Ab3BSLau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 06:30:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGhhbmsgeW91IEVyaWMhICBJJ2xsIGxvb2sgYXQgdGhpcyBpbiBkZXRhaWwgdG9kYXkKCk5laWwK
CkVyaWMgRHVtYXpldCA8ZXJpYy5kdW1hemV0QGdtYWlsLmNvbT4gd3JvdGU6Cgo+U29tZSBzdHJh
bmdlIGNyYXNoZXMgaGFwcGVuIGluIHJ0Nl9jaGVja19leHBpcmVkKCksIHdpdGggYWNjZXNzCj50
byByYW5kb20gYWRkcmVzc2VzLgo+Cj5BdCBmaXJzdCBnbGFuY2UsIGl0IGxvb2tzIGxpa2UgdGhl
IFJURl9FWFBJUkVTIGFuZAo+c3R1ZmYgYWRkZWQgaW4gY29tbWl0IDE3MTZhOTYxMDFjNDkxODZi
Cj4oaXB2NjogZml4IHByb2JsZW0gd2l0aCBleHBpcmVkIGRzdCBjYWNoZSkKPmFyZSByYWN5IDog
c2FtZSBkc3QgY291bGQgYmUgbWFuaXB1bGF0ZWQgYXQgdGhlIHNhbWUgdGltZQo+b24gZGlmZmVy
ZW50IGNwdXMuCj4KPkF0IHNvbWUgcG9pbnQsIG91ciBzdGFjayBiZWxpZXZlcyBydC0+ZHN0LmZy
b20gY29udGFpbnMgYSBkc3QgcG9pbnRlciwKPndoaWxlIGl0cyByZWFsbHkgYSBqaWZmaWUgdmFs
dWUgKGFzIHJ0LT5kc3QuZXhwaXJlcyBzaGFyZXMgdGhlIHNhbWUgYXJlYQo+b2YgbWVtb3J5KQo+
Cj5ydDZfdXBkYXRlX2V4cGlyZXMoKSBzaG91bGQgYmUgZml4ZWQsIG9yIGFtIEkgbWlzc2luZyBz
b21ldGhpbmcgPwo+Cj5DQyBOZWlsIGJlY2F1c2Ugb2YgaHR0cHM6Ly9idWd6aWxsYS5yZWRoYXQu
Y29tL3Nob3dfYnVnLmNnaT9pZD04OTIwNjAKPgo+Cj4KPgo=
