From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH] be2net: fix a race in be_xmit()
Date: Fri, 8 Jun 2012 03:06:14 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F647C6A0B900@EXMAIL.ad.emulex.com>
References: <1339145999.6001.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>
To: <eric.dumazet@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:49536 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754503Ab2FHKGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 06:06:39 -0400
In-Reply-To: <1339145999.6001.62.camel@edumazet-glaptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj5Gcm9tOiBFcmljIER1bWF6ZXQgPGVkdW1h
emV0QGdvb2dsZS5jb20+DQo+DQo+QXMgc29vbiBhcyBoYXJkd2FyZSBpcyBub3RpZmllZCBvZiBh
IHRyYW5zbWl0LCB3ZSBubyBsb25nZXIgY2FuIGFzc3VtZQ0KPnNrYiBjYW4gYmUgZGVyZWZlcmVu
Y2VkLCBhcyBUWCBjb21wbGV0aW9uIG1pZ2h0IGhhdmUgZnJlZWQgdGhlIHBhY2tldC4NCj4NCj5T
aWduZWQtb2ZmLWJ5OiBFcmljIER1bWF6ZXQgPGVkdW1hemV0QGdvb2dsZS5jb20+DQo+Q2M6IFNh
dGh5YSBQZXJsYSA8c2F0aHlhLnBlcmxhQGVtdWxleC5jb20+DQoNCkdvb2QgY2F0Y2guIFRoYW5r
cyENCkFja2VkLWJ5OiBTYXRoeWEgUGVybGEgPHNhdGh5YS5wZXJsYUBlbXVsZXguY29tPg0K
