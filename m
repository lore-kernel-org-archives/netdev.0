From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Fix inet6_csk_bind_conflict so it
 builds with user namespaces enabled
Date: Tue, 29 Jan 2013 15:20:58 -0500 (EST)
Message-ID: <20130129.152058.125290063772024411.davem@davemloft.net>
References: <alpine.DEB.2.00.1301201542470.2060@pokey.mtv.corp.google.com>
	<871ud4chgt.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, netdev@markandruth.co.uk,
	eric.dumazet@gmail.com, therbert@google.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751647Ab3A2UVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:21:00 -0500
In-Reply-To: <871ud4chgt.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogZWJpZWRlcm1AeG1pc3Npb24uY29tIChFcmljIFcuIEJpZWRlcm1hbikNCkRhdGU6IFR1
ZSwgMjkgSmFuIDIwMTMgMDQ6MTY6MTggLTA4MDANCg0KPiANCj4gV2hlbiBhdHRlbXB0aW5nIHRv
IGJ1aWxkIGxpbnV4LW5leHQgd2l0aCB1c2VyIG5hbWVzcGFjZXMgZW5hYmxlZCBJIHJhbg0KPiBp
bnRvIHRoaXMgZnVuIGJ1aWxkIGVycm9yLg0KPiANCj4gICBDQyAgICAgIG5ldC9pcHY2L2luZXQ2
X2Nvbm5lY3Rpb25fc29jay5vDQo+IC4uLi9uZXQvaXB2Ni9pbmV0Nl9jb25uZWN0aW9uX3NvY2su
YzogSW4gZnVuY3Rpb24goWluZXQ2X2Nza19iaW5kX2NvbmZsaWN0ojoNCj4gLi4uL25ldC9pcHY2
L2luZXQ2X2Nvbm5lY3Rpb25fc29jay5jOjM3OjEyOiBlcnJvcjogaW5jb21wYXRpYmxlIHR5cGVz
IHdoZW4gaW5pdGlhbGl6aW5nIHR5cGUgoWludKIgdXNpbmcNCj4gIHR5cGUgoWt1aWRfdKINCj4g
Li4uL25ldC9pcHY2L2luZXQ2X2Nvbm5lY3Rpb25fc29jay5jOjU0OjMwOiBlcnJvcjogaW5jb21w
YXRpYmxlIHR5cGUgZm9yIGFyZ3VtZW50IDEgb2YgoXVpZF9lcaINCj4gLi4uL2luY2x1ZGUvbGlu
dXgvdWlkZ2lkLmg6NDg6MjA6IG5vdGU6IGV4cGVjdGVkIKFrdWlkX3SiIGJ1dCBhcmd1bWVudCBp
cyBvZiB0eXBlIKFpbnSiDQo+IG1ha2VbM106ICoqKiBbbmV0L2lwdjYvaW5ldDZfY29ubmVjdGlv
bl9zb2NrLm9dIEVycm9yIDENCj4gbWFrZVsyXTogKioqIFtuZXQvaXB2Nl0gRXJyb3IgMg0KPiBt
YWtlWzJdOiAqKiogV2FpdGluZyBmb3IgdW5maW5pc2hlZCBqb2JzLi4uLg0KPiANCj4gVXNpbmcg
a3VpZF90IGluc3RlYWQgb2YgaW50IHRvIGhvbGQgdGhlIHVpZCBmaXhlcyB0aGlzLg0KPiANCj4g
Q2M6IFRvbSBIZXJiZXJ0IDx0aGVyYmVydEBnb29nbGUuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiAi
RXJpYyBXLiBCaWVkZXJtYW4iIDxlYmllZGVybUB4bWlzc2lvbi5jb20+DQoNCkFwcGxpZWQsIHRo
YW5rcyBFcmljLg0K
