From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: fix redefinition of in6_pktinfo and
 ip6_mtuinfo
Date: Thu, 08 Jan 2015 19:38:19 -0800 (PST)
Message-ID: <20150108.193819.258816805892789860.davem@davemloft.net>
References: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, carlos@redhat.com, vlee@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbbAIDcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:32:35 -0500
In-Reply-To: <1420587932-8733-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nIDx4aXlvdS53YW5nY29uZ0BnbWFpbC5jb20+DQpEYXRlOiBUdWUsICA2
IEphbiAyMDE1IDE1OjQ1OjMxIC0wODAwDQoNCj4gQm90aCBuZXRpbmV0L2luLmggYW5kIGxpbnV4
L2lwdjYuaCBkZWZpbmUgdGhlc2UgdHdvIHN0cnVjdHMsDQo+IGlmIHdlIGluY2x1ZGUgYm90aCBv
ZiB0aGVtLCB3ZSBnb3Q6DQo+IA0KPiAJL3Vzci9pbmNsdWRlL2xpbnV4L2lwdjYuaDoxOTo4OiBl
cnJvcjogcmVkZWZpbml0aW9uIG9mIKFzdHJ1Y3QgaW42X3BrdGluZm+iDQo+IAkgc3RydWN0IGlu
Nl9wa3RpbmZvIHsNCj4gCQleDQo+IAlJbiBmaWxlIGluY2x1ZGVkIGZyb20gL3Vzci9pbmNsdWRl
L2FycGEvaW5ldC5oOjIyOjAsDQo+IAkJCSBmcm9tIHR4dGltZXN0YW1wLmM6MzM6DQo+IAkvdXNy
L2luY2x1ZGUvbmV0aW5ldC9pbi5oOjUyNDo4OiBub3RlOiBvcmlnaW5hbGx5IGRlZmluZWQgaGVy
ZQ0KPiAJIHN0cnVjdCBpbjZfcGt0aW5mbw0KPiAJCV4NCj4gCUluIGZpbGUgaW5jbHVkZWQgZnJv
bSB0eHRpbWVzdGFtcC5jOjQwOjA6DQo+IAkvdXNyL2luY2x1ZGUvbGludXgvaXB2Ni5oOjI0Ojg6
IGVycm9yOiByZWRlZmluaXRpb24gb2YgoXN0cnVjdCBpcDZfbXR1aW5mb6INCj4gCSBzdHJ1Y3Qg
aXA2X210dWluZm8gew0KPiAJCV4NCj4gCUluIGZpbGUgaW5jbHVkZWQgZnJvbSAvdXNyL2luY2x1
ZGUvYXJwYS9pbmV0Lmg6MjI6MCwNCj4gCQkJIGZyb20gdHh0aW1lc3RhbXAuYzozMzoNCj4gCS91
c3IvaW5jbHVkZS9uZXRpbmV0L2luLmg6NTMxOjg6IG5vdGU6IG9yaWdpbmFsbHkgZGVmaW5lZCBo
ZXJlDQo+IAkgc3RydWN0IGlwNl9tdHVpbmZvDQo+IAkJXg0KPiBTbyBzaW1pbGFybHkgdG8gd2hh
dCB3ZSBkaWQgZm9yIGluNl9hZGRyLCB3ZSBuZWVkIHRvIHN5bmMgd2l0aA0KPiBsaWJjIGhlYWRl
ciBvbiB0aGVpciBkZWZpbml0aW9ucy4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IENvbmcgV2FuZyA8
eGl5b3Uud2FuZ2NvbmdAZ21haWwuY29tPg0KDQpBcHBsaWVkLg0K
