From: Peter Chen <peter.chen@nxp.com>
Subject: RE: [PATCH 06/15] ethernet: hisilicon: hns: hns_dsaf_mac: add missing
 of_node_put after calling of_parse_phandle
Date: Thu, 28 Jul 2016 03:43:08 +0000
Message-ID: <HE1PR04MB1450F5FFDD38BB2B99ED24A68B000@HE1PR04MB1450.eurprd04.prod.outlook.com>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
 <1469586048-15697-7-git-send-email-peter.chen@nxp.com>
 <579953F0.5010906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"vbridger@opensource.altera.com" <vbridger@opensource.altera.com>,
	"isubramanian@apm.com" <isubramanian@apm.com>,
	"kchudgar@apm.com" <kchudgar@apm.com>,
	"salil.mehta@huawei.com" <salil.mehta@huawei.com>,
	"thomas.petazzoni@free-electrons.com"
	<thomas.petazzoni@free-electrons.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"alexandre.torgue@st.com" <alexandre.torgue@st.com>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"wxt@rock-chips.com" <wxt@rock-chips.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"david.daney@cavium.com" <david.daney@cavium.com>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"jszhang@marvell.com" <jszhang@marvell.com>
To: Yisen Zhuang <Yisen.zhuang@huawei.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0060.outbound.protection.outlook.com ([104.47.2.60]:14822
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757132AbcG1GPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 02:15:04 -0400
In-Reply-To: <579953F0.5010906@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IA0KPuWcqCAyMDE2LzcvMjcgMTA6MjAsIFBldGVyIENoZW4g5YaZ6YGTOg0KPj4gb2Zfbm9kZV9w
dXQgbmVlZHMgdG8gYmUgY2FsbGVkIHdoZW4gdGhlIGRldmljZSBub2RlIHdoaWNoIGlzIGdvdCBm
cm9tDQo+PiBvZl9wYXJzZV9waGFuZGxlIGhhcyBmaW5pc2hlZCB1c2luZy4NCj4+DQo+PiBTaWdu
ZWQtb2ZmLWJ5OiBQZXRlciBDaGVuIDxwZXRlci5jaGVuQG54cC5jb20+DQo+PiAtLS0NCj4+ICBk
cml2ZXJzL25ldC9ldGhlcm5ldC9oaXNpbGljb24vaG5zL2huc19kc2FmX21hYy5jIHwgOSArKysr
KystLS0NCj4+ICAxIGZpbGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygt
KQ0KPj4NCj4+IGRpZmYgLS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9oaXNpbGljb24vaG5z
L2huc19kc2FmX21hYy5jDQo+PiBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2hpc2lsaWNvbi9obnMv
aG5zX2RzYWZfbWFjLmMNCj4+IGluZGV4IDNmYjg3ZTIuLjE4ZDcyZWEgMTAwNjQ0DQo+PiAtLS0g
YS9kcml2ZXJzL25ldC9ldGhlcm5ldC9oaXNpbGljb24vaG5zL2huc19kc2FmX21hYy5jDQo+PiAr
KysgYi9kcml2ZXJzL25ldC9ldGhlcm5ldC9oaXNpbGljb24vaG5zL2huc19kc2FmX21hYy5jDQo+
PiBAQCAtNzg2LDYgKzc4Niw3IEBAIHN0YXRpYyBpbnQgIGhuc19tYWNfZ2V0X2luZm8oc3RydWN0
IGhuc19tYWNfY2IgKm1hY19jYikNCj4+ICAJCW5wID0gb2ZfcGFyc2VfcGhhbmRsZShtYWNfY2It
PmRldi0+b2Zfbm9kZSwgInBoeS1oYW5kbGUiLA0KPj4gIAkJCQkgICAgICBtYWNfY2ItPm1hY19p
ZCk7DQo+PiAgCQltYWNfY2ItPnBoeV9kZXYgPSBvZl9waHlfZmluZF9kZXZpY2UobnApOw0KPj4g
KwkJb2Zfbm9kZV9wdXQobnApOw0KPj4gIAkJaWYgKG1hY19jYi0+cGh5X2Rldikgew0KPj4gIAkJ
CS8qIHJlZmNvdW50IGlzIGhlbGQgYnkgb2ZfcGh5X2ZpbmRfZGV2aWNlKCkNCj4+ICAJCQkgKiBp
ZiB0aGUgcGh5X2RldiBpcyBmb3VuZA0KPg0KPm5wIGlzIGFjY2Vzc2VkIGluIGNhc2Ugb2Ygb2Zf
cGh5X2ZpbmRfZGV2aWNlKCkgcmV0dXJucyBhIG5vIG51bGwgdmFsdWUsIHNvIGl0IGhhcyB0byBi
ZQ0KPm1vdmVkIGFmdGVyIHRoZSBkZXZfZGJnIGxvZy4NCj4NCj4+IEBAIC04MDQsNiArODA1LDcg
QEAgc3RhdGljIGludCAgaG5zX21hY19nZXRfaW5mbyhzdHJ1Y3QgaG5zX21hY19jYiAqbWFjX2Ni
KQ0KPj4gIAkJbnAgPSBvZl9wYXJzZV9waGFuZGxlKHRvX29mX25vZGUobWFjX2NiLT5md19wb3J0
KSwNCj4+ICAJCQkJICAgICAgInBoeS1oYW5kbGUiLCAwKTsNCj4+ICAJCW1hY19jYi0+cGh5X2Rl
diA9IG9mX3BoeV9maW5kX2RldmljZShucCk7DQo+PiArCQlvZl9ub2RlX3B1dChucCk7DQo+PiAg
CQlpZiAobWFjX2NiLT5waHlfZGV2KSB7DQo+PiAgCQkJLyogcmVmY291bnQgaXMgaGVsZCBieSBv
Zl9waHlfZmluZF9kZXZpY2UoKQ0KPj4gIAkJCSAqIGlmIHRoZSBwaHlfZGV2IGlzIGZvdW5kDQo+
DQo+bnAgaXMgYWNjZXNzZWQgaW4gY2FzZSBvZiBvZl9waHlfZmluZF9kZXZpY2UoKSByZXR1cm5z
IGEgbm8gbnVsbCB2YWx1ZSwgc28gaXQgaGFzIHRvIGJlDQo+bW92ZWQgYWZ0ZXIgdGhlIGRldl9k
YmcgbG9nLg0KPg0KDQpUaGFua3MsIEkgd2lsbCBjaGFuZ2UgdGhlbS4NCg0KUGV0ZXINCg0K
