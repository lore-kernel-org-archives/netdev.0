From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net v2 3/4] r8152: re-schedule napi for tx
Date: Thu, 26 Jan 2017 01:22:07 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB201A136FC@RTITMBSV06.realtek.com.tw>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
         <1394712342-15778-242-Taiwan-albertk@realtek.com>
         <1394712342-15778-245-Taiwan-albertk@realtek.com>
 <1485352637.5145.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:38738 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdAZBWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 20:22:13 -0500
In-Reply-To: <1485352637.5145.4.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RXJpYyBEdW1hemV0IFttYWlsdG86ZXJpYy5kdW1hemV0QGdtYWlsLmNvbV0NCj4gU2VudDogV2Vk
bmVzZGF5LCBKYW51YXJ5IDI1LCAyMDE3IDk6NTcgUE0NClsuLi5dDQo+ID4gIAkJbmFwaV9jb21w
bGV0ZShuYXBpKTsNCj4gPiAgCQlpZiAoIWxpc3RfZW1wdHkoJnRwLT5yeF9kb25lKSkNCj4gPiAg
CQkJbmFwaV9zY2hlZHVsZShuYXBpKTsNCj4gPiArCQllbHNlIGlmICghc2tiX3F1ZXVlX2VtcHR5
KCZ0cC0+dHhfcXVldWUpICYmDQo+ID4gKwkJCSAhbGlzdF9lbXB0eSgmdHAtPnR4X2ZyZWUpKQ0K
PiA+ICsJCQluYXBpX3NjaGVkdWxlKCZ0cC0+bmFwaSk7DQo+IA0KPiBXaHkgdXNpbmcgJnRwLT5u
YXBpIGluc3RlYWQgb2YgbmFwaSBoZXJlLCBhcyBkb25lIDMgbGluZXMgYWJvdmUgPw0KDQpPb3Bz
LiBJIHdvdWxkIGZpeCBpdC4gVGhhbmtzLg0KDQpCZXN0IFJlZ2FyZHMsDQpIYXllcw0KDQoNCg==
