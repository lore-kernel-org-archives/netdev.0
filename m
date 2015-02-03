From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH net-next 1/2] pkt_sched: fq: avoid artificial bursts for
 clocked flows
Date: Tue, 3 Feb 2015 19:51:46 +0000
Message-ID: <F3E6220B-F2F4-4985-AECE-9EB9AA7D1C20@ifi.uio.no>
References: <1422903556-30393-1-git-send-email-kennetkl@ifi.uio.no>
 <1422905092.21689.122.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out5.uio.no ([129.240.10.17]:44068 "EHLO mail-out5.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756148AbbBCTvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 14:51:50 -0500
In-Reply-To: <1422905092.21689.122.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <331E918E6F71014B9AEB80A4AC9DC259@mail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IE9uIDAyIEZlYiAyMDE1LCBhdCAyMDoyNCwgRXJpYyBEdW1hemV0IDxlcmljLmR1bWF6ZXRA
Z21haWwuY29tPiB3cm90ZToNCj4gDQo+IE9uIE1vbiwgMjAxNS0wMi0wMiBhdCAxOTo1OSArMDEw
MCwgS2VubmV0aCBLbGV0dGUgSm9uYXNzZW4gd3JvdGU6DQo+PiBDdXJyZW50IHBhY2luZyBiZWhh
dmlvciBhbHdheXMgdGhyb3R0bGUgZmxvd3MgZm9yIGEgdGltZSBlcXVhbCB0byBvbmUgZnVsbA0K
Pj4gcXVhbnR1bSwgc3RhcnRpbmcgYXQgdGhlIGluc3RhbmNlIGluIHRpbWUgd2hlbiBhIGZsb3cg
ZGVwbGV0ZXMgaXRzIGNyZWRpdC4NCj4+IOKApg0KPiANCj4gDQo+IFdlIGRvIG5vdCB3YW50IHRv
IHBlcmZlY3RseSBzcGFjZSBwYWNrZXRzLCBidXQgaGF2ZSBhbiBlZmZpY2llbnQgcGFja2V0DQo+
IHNjaGVkdWxlciwgYWxsb3dpbmcgVENQIHBhY2luZy4NCj4gDQo+IEkgY2hvc2UgdG8gbm90IHVz
ZSBrdGltZV9nZXQoKSBpbiBlbnF1ZXVlKCkgd2hlbiBJIHdyb3RlIHNjaF9mcS4NClBvc3RlZCBW
MiB0byBhZGRyZXNzIHRoaXMuDQoNCj4gDQo+IEEgVG9rZW4gQnVja2V0IEZpbHRlciBoYXMgdGhl
IG5vdGlvbiBvZiBxdWFudHVtLCBtZWFuaW5nIHlvdSBjb25maWd1cmUNCj4gdGhlIGdyYW51bGFy
aXR5IGdpdmVuIHRoaXMgcXVhbnR1bS4NCj4gDQo+IEF0IEdvb2dsZSwgd2UgaGF2ZSBhIHNwZWNp
YWwgaGFuZGxpbmcgZm9yIFRDUCBBQ0sgcGFja2V0cywgc28gdGhhdCB0aGV5DQo+IGRvIG5vdCBp
bnRlcmZlcmUgd2l0aCBGUS9wYWNpbmcuDQpJbnRlcmVzdGluZy4gSG93IGRvZXMgdGhpcyB3b3Jr
IHdoZW4gQUNLcyBhcmUgcGlnZ3liYWNrZWQgdG8gZGF0YT8NCg0KPiANCj4gQUNLIHBhY2tldHMg
YXJlIG5vdCBwYWNlZCwgZXZlci4NCj4gDQo+IFRoaXMgcGF0Y2ggYWxzbyBhbGxvd3Mgc2tiLT5v
b29fb2theSBiZWluZyBzZXQgZXZlbiBpZiB0aGUgREFUQSBwYWNrZXQNCj4gaW1tZWRpYXRlbHkg
Zm9sbG93cyBhIHRyYWluIG9mIEFDSyBwYWNrZXRzIChhcyBpbiB0eXBpY2FsIFJQQyBwYXR0ZXJu
cykNCj4gDQpDb3VsZCB5b3UgcGxlYXNlIGV4cGFuZCBvbiB0aGlzPw0KDQpUaGFua3MgZm9yIHRo
ZSBmZWVkYmFjayBzbyBmYXIuDQoNClNpbmNlcmVseSwNCktlbm5ldGg=
