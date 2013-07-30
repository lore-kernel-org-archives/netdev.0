From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net/fec: Don't let ndo_start_xmit return NETDEV_TX_BUSY
 without link
Date: Tue, 30 Jul 2013 09:59:20 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015DC3C7@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <florian@openwrt.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?utf-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0187.outbound.messaging.microsoft.com ([213.199.154.187]:15171
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755773Ab3G3J71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 05:59:27 -0400
In-Reply-To: <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCBKdWwgMzAsIDIwMTMgYXQgMDU6MzAgUE0sIFV3ZSBLbGVpbmUtS8O2bmlnIDx1Lmts
ZWluZS1rb2VuaWdAcGVuZ3V0cm9uaXguZGU+IHdyb3RlOg0KDQo+RG9uJ3QgdGVzdCBmb3IgaGF2
aW5nIGxpbmsgYW5kIGxldCBoYXJkd2FyZSBkZWFsIHdpdGggdGhpcyBzaXR1YXRpb24uDQo+DQo+
V2l0aG91dCB0aGlzIHBhdGNoIEkgc2VlIGEgbWFjaGluZSBydW5uaW5nIGFuIC1ydCBwYXRjaGVk
IExpbnV4IGJlaW5nIHN0dWNrIGluIHNjaF9kaXJlY3RfeG1pdCB3aGVuIGl0IGxvb3NlcyBsaW5r
IHdoaWxlIHRoZXJlIGlzIHN0aWxsIGEgcGFja2V0IHRvIGJlIHNlbnQuIA0KPkluIHRoaXMgY2Fz
ZSB0aGUgZmVjX2VuZXRfc3RhcnRfeG1pdCByb3V0aW5lIHJldHVybmVkIE5FVERFVl9UWF9CVVNZ
IHdoaWNoIG1ha2VzIHRoZSBuZXR3b3JrIHN0YWNrIHJlc2NoZWR1bGUgdGhlIHBhY2tldCBhbmQg
c28gc2NoX2RpcmVjdF94bWl0IGNhbGxzDQo+ZmVjX2VuZXRfc3RhcnRfeG1pdCBhZ2Fpbi4NCj5J
IGZhaWxlZCB0byByZXByb2R1Y2UgYSBjb21wbGV0ZSBoYW5nIHdpdGhvdXQgLXJ0LCBidXQgSSB0
aGluayB0aGUgcHJvYmxlbSBleGlzdHMgdGhlcmUsIHRvby4NCj4NCj5TaWduZWQtb2ZmLWJ5OiBV
d2UgS2xlaW5lLUs/bmlnIDx1LmtsZWluZS1rb2VuaWdAcGVuZ3V0cm9uaXguZGU+DQoNCkFja2Vk
LWFuZC10ZXN0ZWQtYnk6IEZ1Z2FuZyBEdWFuICA8QjM4NjExQGZyZWVzY2FsZS5jb20+DQoNCg==
