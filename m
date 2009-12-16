From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH v2 1/2] ixgbe: Fix
 tx_restart_queue/non_eop_desc statistics counters
Date: Tue, 15 Dec 2009 23:16:51 -0800 (PST)
Message-ID: <20091215.231651.144154754.davem@davemloft.net>
References: <20091215215636.25793.78144.stgit@localhost.localdomain>
	<20091215.211354.189718802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933106AbZLPHQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 02:16:51 -0500
In-Reply-To: <20091215.211354.189718802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAxNSBE
ZWMgMjAwOSAyMToxMzo1NCAtMDgwMCAoUFNUKQ0KDQo+IEZyb206IEplZmYgS2lyc2hlciA8amVm
ZnJleS50LmtpcnNoZXJAaW50ZWwuY29tPg0KPiBEYXRlOiBUdWUsIDE1IERlYyAyMDA5IDEzOjU2
OjU5IC0wODAwDQo+IA0KPj4gRnJvbTogTWFsbGlrYXJqdW5hIFIgQ2hpbGFrYWxhIDxtYWxsaWth
cmp1bmEuY2hpbGFrYWxhQGludGVsLmNvbT4NCj4+IA0KPj4gRml4IHRoZSByZXN0YXJ0X3F1ZXVl
IGFuZCBub25fZW9wX2Rlc2MgY291bnRlcnMgZnJvbSBiZWluZw0KPj4gZG91YmxlLWNvdW50ZWQu
ICBUaGV5IGFyZSBjdW11bGF0aXZlIGluIGVhY2ggcmluZywgc28gd2UgZG9uJ3Qgd2FudCB0bw0K
Pj4gYWRkIHRoZW0gdG8gdGhlIGN1bXVsYXRpdmUgcmVzdWx0IGluIHRoZSBhZGFwdGVyJ3MgbWFz
dGVyIGNvdW50ZXIuDQo+PiBPdGhlcndpc2UsIHRoZSBzdGF0cyB3aWxsIGJlIGluYWNjdXJhdGUN
Cj4+IA0KPj4gU2lnbmVkLW9mZi1ieTogIE1hbGxpa2FyanVuYSBSIENoaWxha2FsYSA8bWFsbGlr
YXJqdW5hLmNoaWxha2FsYUBpbnRlbC5jb20+DQo+PiBBY2tlZC1ieTogUGV0ZXIgUCBXYXNraWV3
aWN6IEpyIDxwZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tPg0KPj4gU2lnbmVkLW9mZi1i
eTogSmVmZiBLaXJzaGVyIDxqZWZmcmV5LnQua2lyc2hlckBpbnRlbC5jb20+DQo+IA0KPiBBcHBs
aWVkLg0KDQpTbyBob3cgZGlkIHlvdSBidWlsZCB0ZXN0IHRoaXM/DQoNCmRyaXZlcnMvbmV0L2l4
Z2JlL2l4Z2JlX21haW4uYzogSW4gZnVuY3Rpb24goWl4Z2JlX3VwZGF0ZV9zdGF0c6I6DQpkcml2
ZXJzL25ldC9peGdiZS9peGdiZV9tYWluLmM6NDUzMjogZXJyb3I6IGludmFsaWQgdHlwZSBhcmd1
bWVudCBvZiChLT6iIChoYXZlIKFzdHJ1Y3QgaXhnYmVfcmluZ6IpDQpkcml2ZXJzL25ldC9peGdi
ZS9peGdiZV9tYWluLmM6NDUzNjogZXJyb3I6IGludmFsaWQgdHlwZSBhcmd1bWVudCBvZiChLT6i
IChoYXZlIKFzdHJ1Y3QgaXhnYmVfcmluZ6IpDQo=
