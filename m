From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix uninitialized variable warning
Date: Tue, 13 Jan 2015 16:39:52 -0500 (EST)
Message-ID: <20150113.163952.485624770798336701.davem@davemloft.net>
References: <1421108728-12778-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36403 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbbAMVjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:39:54 -0500
In-Reply-To: <1421108728-12778-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogcm9vcGFAY3VtdWx1c25ldHdvcmtzLmNvbQ0KRGF0ZTogTW9uLCAxMiBKYW4gMjAxNSAx
NjoyNToyOCAtMDgwMA0KDQo+IEZyb206IFJvb3BhIFByYWJodSA8cm9vcGFAY3VtdWx1c25ldHdv
cmtzLmNvbT4NCj4gDQo+IG5ldC9icmlkZ2UvYnJfbmV0bGluay5jOiBJbiBmdW5jdGlvbiChYnJf
ZmlsbF9pZmluZm+iOg0KPiBuZXQvYnJpZGdlL2JyX25ldGxpbmsuYzoxNDY6MzI6IHdhcm5pbmc6
IKF2aWRfcmFuZ2VfZmxhZ3OiIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5j
dGlvbiBbLVdtYXliZS11bmluaXRpYWxpemVkXQ0KPiAgIGVyciA9IGJyX2ZpbGxfaWZ2bGFuaW5m
b19yYW5nZShza2IsIHZpZF9yYW5nZV9zdGFydCwNCj4gICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICBeDQo+IG5ldC9icmlkZ2UvYnJfbmV0bGluay5jOjEwODo2OiBub3RlOiChdmlkX3Jh
bmdlX2ZsYWdzoiB3YXMgZGVjbGFyZWQgaGVyZQ0KPiAgIHUxNiB2aWRfcmFuZ2VfZmxhZ3M7DQo+
IA0KPiBSZXBvcnRlZC1ieTogVGhvbWFzIEdyYWYgPHRncmFmQHN1dWcuY2g+DQo+IFNpZ25lZC1v
ZmYtYnk6IFJvb3BhIFByYWJodSA8cm9vcGFAY3VtdWx1c25ldHdvcmtzLmNvbT4NCg0KQXBwbGll
ZCwgdGhhbmsgeW91Lg0K
