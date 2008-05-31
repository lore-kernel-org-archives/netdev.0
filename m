From: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 22:25:22 +0200
Message-ID: <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
	 <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
	 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
	 <484191BD.8000904@gmail.com>
	 <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
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
Received: from rv-out-0506.google.com ([209.85.198.234]:42518 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbYEaUZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 16:25:23 -0400
Received: by rv-out-0506.google.com with SMTP id l9so396208rvb.1
        for <netdev@vger.kernel.org>; Sat, 31 May 2008 13:25:22 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAwOC81LzMxIElscG8gSsOkcnZpbmVuIDxpbHBvLmphcnZpbmVuQGhlbHNpbmtpLmZpPjoKPiBP
aywgbGlrZSB5b3Ugc2FpZCwgdGhpcyBpcyBub3QgZXhhY3RseSB0aGUgc2FtZSwgdGhvdWdoIGl0
IG1pZ2h0IGJlIGR1ZSB0bwo+IHRoZSBzYW1lIGJ1Zy4gSW4gSW5nbydzIGNhc2UgYm90aCBlbmRw
b2ludHMgd2VyZSBkb2luZyBwcmV0dHkgaGVhbHRpbHksCj4gd2l0aCBwZXJpb2RpYyB3aW5kb3cg
cHJvYmVzIGFzIGV4cGVjdGVkLiBJbiB5b3VyIGNhc2UgVENQIGlzIG5vdCBkb2luZwo+IHdpbmRv
dyBwcm9iZXMgYnV0IGdvdCB0aGF0IGludGVyZXN0aW5nIFJUTyB2YWx1ZS4KPgo+IFNvIHlvdSBo
YWQgdGhhdCAnLScgZWFybGllciBhbmQgeW91IGNoZWNrZWQgYXQgdGhhdCB0aW1lIGJ1dCB0aGUK
PiBjb25uZWN0aW9uIGlzIG5vdyBhbHJlYWR5IGRlYWQ/CgpUaGlzIGlzIG9ubHkgZnJvbSBjaGVj
a2luZyBhZnRlciB0aGUgY29ubmVjdGlvbiB3YXMgZGVhZC4gQnkgdGhlIHdheSwKSSBqdXN0IGhh
ZCB0byByZW1vdGVseSByZWJvb3QgdGhlIG5ldyBtYWNoaW5lIGJlY2F1c2UgdGhlIHdpbmRvdwpt
YW5hZ2VyIGxvY2tlZCB1cCwgaG93ZXZlciB0aGUgb2xkIFBDIGFyZSBzdGlsbCBsaXN0aW5nIHRo
ZSBkZWZ1bmN0CmNvbm5lY3Rpb25zIGFmdGVyIHRoaXMuCgoKPiA6LSgsIEkgd291bGQgc29tZSBt
dWNoIGxpa2VkIHRvIHNlZSB3aGF0IHRoZXkgd2VyZSBkb2luZy4KCkkgY2FuIG9mIGNvdXJzZSBr
ZWVwIG9uIGNvcHlpbmcgZm9yIHRlc3RpbmcgcHVycG9zZXMsIGJ1dCB0aGVuIEkgd291bGQgbGlr
ZSB0bwpiZSBhYmxlIHRvIGR1bXAgb25seSB0aGF0IHNpbmdsZSB0Y3AgY29ubmVjdGlvbiwgYW55
IHRpcHMgb2YgaG93IHRvIGRvIHRoYXQ/CkkgZm91bmQgbm90aGluZyBzcGVjaWZpYyBpbiB0aGUg
bWFudWFscyBvZiB3aXJlc2hhcmsgYW5kIHRjcGR1bXAuIE9mIGNvdXJzZQppdCBpcyBwb3NzaWJs
ZSB0byBjYXB0dXJlIGV2ZXJ5dGhpbmcgYW5kIGZpbHRlciBhZnRlcndhcmRzLCBidXQgc2luY2Ug
SSB3aWxsIGJlCnRyYW5zZmVycmluZyBsb3RzIG9mIGRhdGEgdGhlIGxvZ3Mgd2lsbCBnZXQgaHVn
ZSBhbmQgSSB3b3VsZCBub3QgbGlrZSB0byBoYXZlCmV2ZW4gYWRkaXRpb25hbCB0cmFmZmljIGlu
c2lkZS4uLgoKCj4gVGhlc2UgN0MvRC4uLiBjZXJ0YWlubHkgc2VlbSBzdHJhbmdlIHZhbHVlcy4g
V2hpY2ggVENQIHZhcmlhbnQgeW91IGhhdmUgaW4KPiB1c2UgKGNhdCAvcHJvYy9zeXMvbmV0L2lw
djQvdGNwX2Nvbmdlc3Rpb25fY29udHJvbCk/IEl0IHNlZW1zIHRoYXQgdmVnYXMsCj4gdmVubyBh
bmQgeWVhaCBhdCBsZWFzdCBjb250YWluIDB4N2ZmZmZmZmYgdGhlcmUgZm9yIHNvbWUgcnR0LCB3
aGljaCBjb3VsZAo+IHBlcmhhcHMgc29tZWhvdyBsZWFrLgoKSSBoYXZlIG5vdCBkb25lIGFueSBz
cGVjaWZpYyBzZWxlY3Rpb24gbXlzZWxmLiBPbiBvbGRfcGM6IGJpYywgbmV3X3BjOiBjdWJpYy4K
CkJSIEjDpWtvbiBMw7h2ZGFsCg==
