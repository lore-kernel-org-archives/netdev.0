From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: RE: [PATCH net-next 11/13] net: ethernet: aquantia: Refactoring
 buffers copying.
Date: Thu, 16 Feb 2017 16:37:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE6842A@AcuExch.aculab.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <de4d3c34fac8c7bbbb614f776ca1255fd6aa03a6.1487187192.git.pavel.belous@aquantia.com>
 <4262ef98-4ba5-3f1a-5b72-208be51bdd6f@gmx.de>,
 <063D6719AE5E284EB5DD2968C1650D6DCFE68133@AcuExch.aculab.com>
 <trinity-c726d458-78f5-41bf-8d00-ac6d55a03c35-1487260948543@3capp-gmx-bs24>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: 'Lino Sanfilippo' <LinoSanfilippo@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:58088 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932385AbdBPQhx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:37:53 -0500
In-Reply-To: <trinity-c726d458-78f5-41bf-8d00-ac6d55a03c35-1487260948543@3capp-gmx-bs24>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogTGlubyBTYW5maWxpcHBvDQo+IFNlbnQ6IDE2IEZlYnJ1YXJ5IDIwMTcgMTY6MDINCi4u
Lg0KPiBJIHdhcyByZWZlcnJpbmcgdG8gdGhlIGNvcHkgb2YgdHggZGVzY3JpcHRvcnMsIG5vdCB0
aGUgZnJhbWVzL2ZyYWdtZW50cyBpdHNlbGYuDQo+IEkgd3JvdGUgInR4IGJ1ZmZlcnMiIGJlY2F1
c2UgaW4gdGhpcyBkcml2ZXIgYSBkZXNjcmlwdG9yIGlzIHJlcHJlc2VudGVkIGFzDQo+ICBhIHN0
cnVjdCAiYXFfcmluZ19idWZmX3MiLiBJIGNhbm5vdCBzZWUgYSByZWFzb24gd2h5IHRoaXMgZGVz
Y3JpcHRvciBjb3B5DQo+ICBzaG91bGQgYmUgbmVjZXNzYXJ5Lg0KDQpOb3QgdW5sZXNzIHRoZSBk
ZXNjcmlwdG9yIG1lbW9yeSBpcyBvbiB0aGUgY2FyZC4NCg0KQWN0dWFsbHkgaXQgbWlnaHQgYmUg
d29yc2UgdGhhbiB0aGF0Lg0KVGhlIHRyYW5zbWl0IGRlc2NyaXB0b3IgcHJvYmFibHkgaGFzIGFu
ICdvd25lcicgYml0Lg0KVGhlIHdyaXRlIG9mIHRoZSB3b3JkIGNvbnRhaW5pbmcgdGhhdCBiaXQg
bXVzdCBiZSBsYXN0IGFuZA0KcHJlY2VkZWQgYnkgdGhlIGFwcHJvcHJpYXRlIGJhcnJpZXIgKHBy
b2JhYmx5IGRtYV93bWIoKSkuDQpBbm90aGVyIGJhcnJpZXIgaXMgbmVlZGVkIGJlZm9yZSB0aGUg
J2Rvb3JiZWxsJyBpbyB3cml0ZSB0aGF0IGtpY2tzDQp0aGUgaGFyZHdhcmUuDQoNClVzaW5nIG1l
bWNweSgpIHdvbid0IGhhdmUgdGhhdCBlZmZlY3QgYXQgYWxsLg0KDQpJZiB0aGUgZXRoZXJuZXQg
ZnJhbWUgaXMgZnJhZ21lbnRlZCAoYW5kIHNvIHVzZXMgbXVsdGlwbGUNCmRlc2NyaXB0b3JzKSB0
aGUgb3duZXIgYml0IG9mIHRoZSBmaXJzdCBkZXNjcmlwdG9yIG11c3QgYmUNCmluIHRoZSBsYXN0
IHdyaXRlLg0KDQoJRGF2aWQNCg0K
