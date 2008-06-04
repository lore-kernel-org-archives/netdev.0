From: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Wed, 4 Jun 2008 16:00:29 +0200
Message-ID: <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
	 <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
	 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
	 <484191BD.8000904@gmail.com>
	 <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
	 <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
	 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
	 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
	 <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
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
Received: from rv-out-0506.google.com ([209.85.198.227]:63018 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbYFDOAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 10:00:30 -0400
Received: by rv-out-0506.google.com with SMTP id l9so126623rvb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2008 07:00:30 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MjAwOC82LzQgSWxwbyBKw6RydmluZW4gPGlscG8uamFydmluZW5AaGVsc2lua2kuZmk+Ogo+IE9u
IFdlZCwgNCBKdW4gMjAwOCwgSMOla29uIEzDuHZkYWwgd3JvdGU6Cj4KPj4gSGkuIEkgaGF2ZSBu
b3cgdGVzdGVkIGFuZCB0YWtlbiB2YXJpb3VzIGxvZ3MgYmVmb3JlL3VuZGVyL2FmdGVyIChwcywK
Pj4gbmV0c3RhdCwgdGNwZHVtcCwgc3RyYWNlLCAvcHJvYy9uZXQvdGNwKS4gVGhlIGxvZ3MgZGlk
IG5vdCBncm93IGFzIGJpZwo+PiBhcyBJIGZlYXJlZCBob3dldmVyIHRoZXkgYXJlIHdheSB0b28g
YmlnIGF0dGFjaCBoZXJlLiBBbnkgdGlwcyBvbiBob3cgdG8KPj4gZGlzdHJpYnV0ZT8KPgo+IFVz
dWFsbHkgc3VjaCBsb2dzIGNvbXByZXNzIHF1aXRlIHdlbGwuIEEgYmVzdCB0aGluZyBtaWdodCBi
ZSB0byBwdXQKPiBzb21ld2hlcmUgKGlmIHBvc3NpYmxlKSBhbmQgaHR0cDovLyByZWZlcmVuY2Ug
dGhlbS4KClRoZSBsYXJnZXN0IGZpbGUgd2FzIGEgc3RyYWNlIGxvZyBvZiAxLjVHQiB1bmNvbXBy
ZXNzZWQuIEkgd2lsbCB0cnkgdG8Kc29ydCBvdXQgc29tZXRoaW5nLgoKCj4+IC8vbmV0c3RhdCBi
ZWZvcmUgdGhlIGhhbmc6Cj4+IFByb3RvIFJlY3YtUSBTZW5kLVEgTG9jYWwgQWRkcmVzcyAgICAg
ICAgICAgICAgIEZvcmVpZ24gQWRkcmVzcwo+PiAgICAgIFN0YXRlICAgICAgIFBJRC9Qcm9ncmFt
IG5hbWUgICAgVGltZXIKPj4gdGNwICAgICAgICAwICAgIDUwNCBuZXdfcGM6MjIgICAgICAgICAg
ICAgICAgICAgb2xkX3BjOjM5NDY0Cj4+ICAgICAgRVNUQUJMSVNIRUQgMTcwNTQvc3NoZDogaGxv
dmRhbCBvbiAoMC4yMC8wLzApCj4+Cj4+IC8vIGFmdGVyIHRoZSBoYW5nOgo+PiBQcm90byBSZWN2
LVEgU2VuZC1RIExvY2FsIEFkZHJlc3MgICAgICAgICAgICAgICBGb3JlaWduIEFkZHJlc3MKPj4g
ICAgICBTdGF0ZSAgICAgICBQSUQvUHJvZ3JhbSBuYW1lICAgIFRpbWVyCj4+IHRjcCAgICAgICAg
MCAgIDI4OTYgb2xkX3BjOjIyICAgICAgICAgICAgICAgICAgIG5ld19wYzozOTQ2NAo+PiAgICAg
IEVTVEFCTElTSEVEIC0gICAgICAgICAgICAgICAgICAgb24gKDIxMzI5NDQxLjE5LzAvMCkKPgo+
ID8/PyBBcmUgdGhlc2Ugb24gdGhlIHNhbWUgbWFjaGluZT8gSG93IGNvbWUgdGhlIGlwLWFkZHJl
c3NlcyBnb3QgcmV2ZXJzZWQKPiAod2hpbGUgcG9ydHMgcmVtYWluIHRoZSBzYW1lKS4uLj8hPwoK
T29wcywgdGhhdCB3YXMgYW4gZWRpdGluZyBtaXN0YWtlIG9uIG15IHBhcnQsIG9sZCBhbmQgbmV3
IGFyZSBtaXhlZCB1cAppbiB0aGUgbGFzdCBsaW5lLgoKQlIgSMOla29uIEzDuHZkYWwK
