From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] act_police: fix a crash during removal
Date: Fri, 03 Jun 2016 19:28:41 -0400 (EDT)
Message-ID: <20160603.192841.407832783155363455.davem@davemloft.net>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
	<1464822920-14205-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, stasn77@gmail.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbcFCX2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:28:43 -0400
In-Reply-To: <1464822920-14205-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nIDx4aXlvdS53YW5nY29uZ0BnbWFpbC5jb20+DQpEYXRlOiBXZWQsICAx
IEp1biAyMDE2IDE2OjE1OjIwIC0wNzAwDQoNCj4gVGhlIHBvbGljZSBhY3Rpb24gaXMgdXNpbmcg
aXRzIG93biBjb2RlIHRvIGluaXRpYWxpemUgdGNmIGhhc2gNCj4gaW5mbywgd2hpY2ggbWFrZXMg
dXMgdG8gZm9yZ290IHRvIGluaXRpYWxpemUgYS0+aGluZm8gY29ycmVjdGx5Lg0KPiBGaXggdGhp
cyBieSBjYWxsaW5nIHRoZSBoZWxwZXIgZnVuY3Rpb24gdGNmX2hhc2hfY3JlYXRlKCkgZGlyZWN0
bHkuDQo+IA0KPiBUaGlzIHBhdGNoIGZpeGVkIHRoZSBmb2xsb3dpbmcgY3Jhc2g6DQogLi4uDQo+
IEZpeGVzOiBkZGY5N2NjZGQ3Y2IgKCJuZXRfc2NoZWQ6IGFkZCBuZXR3b3JrIG5hbWVzcGFjZSBz
dXBwb3J0IGZvciB0YyBhY3Rpb25zIikNCj4gQ2M6IEphbWFsIEhhZGkgU2FsaW0gPGpoc0Btb2ph
dGF0dS5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IENvbmcgV2FuZyA8eGl5b3Uud2FuZ2NvbmdAZ21h
aWwuY29tPg0KDQpUaGlzIGFkZHMgYSBuZXcgd2FybmluZywgcGxlYXNlIHJlc3VibWl0IHdpdGgg
dGhpcyBmaXhlZC4NCg0KbmV0L3NjaGVkL2FjdF9wb2xpY2UuYzogSW4gZnVuY3Rpb24goXRjZl9h
Y3RfcG9saWNlX2xvY2F0ZaI6DQpuZXQvc2NoZWQvYWN0X3BvbGljZS5jOjI0NzozOiB3YXJuaW5n
OiChcG9saWNloiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1X
bWF5YmUtdW5pbml0aWFsaXplZF0NCg==
