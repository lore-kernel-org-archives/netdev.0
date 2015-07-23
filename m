From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 2/3] r8152: fix remote wakeup
Date: Thu, 23 Jul 2015 11:30:30 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F3ACFE@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
	 <1394712342-15778-150-Taiwan-albertk@realtek.com>
	 <1437640258.4377.6.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F3AC58@RTITMBSV03.realtek.com.tw>
 <1437647246.4377.33.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1437647246.4377.33.camel-IBi9RG/b67k@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

T2xpdmVyIE5ldWt1bSBbbWFpbHRvOm9uZXVrdW1Ac3VzZS5jb21dDQpbLi4uXQ0KPiBJZiB0aGUg
ZGV2aWNlIGRvZXMgbm90IHN1cHBvcnQgcmVtb3RlIHdha2V1cCBhbmQgdGhlIGRyaXZlciBlbmFi
bGVzIGl0LCBydW50aW1lDQo+IHBvd2VyIG1hbmFnZW1lbnQgd2lsbCBiZSBzd2l0Y2hlZCBvZmYu
DQo+IFRoYXQgaXMgdGhlIGN1cnJlbnQgc3RhdGUgYW5kIGl0IG1lYW5zIHRoYXQgZGV2aWNlcyB3
aGljaCBkb24ndCBzdXBwb3J0IHJlbW90ZQ0KPiB3YWtldXAgY2Fubm90IGRvIHJ1bnRpbWUgcG93
ZXIgbWFuYWdlbWVudCBhdCBhbGwuIEJ1dCB0aGUgZHJpdmVyIGlzIGNvcnJlY3QuDQo+IA0KPiBU
aGUgb25seSB0aW1lIGEgZGV2aWNlIHRoYXQgZG9lc24ndCBzdXBwb3J0IHJlbW90ZSB3YWtldXAg
Y2FuIGRvIHJ1bnRpbWUgcG93ZXINCj4gbWFuYWdlbnQgaXMgd2hlbiBubyBwYWNrZXRzIGNhbiBi
ZSByZWNlaXZlZCB0aGF0IGlzIHdoaWxlIHRoZSBpbnRlcmZhY2UgaXMgZG93bi4gSWYNCj4geW91
IHdhbnQgdG8gYWxsb3cgdGhhdCB5b3UgbXVzdCBub3Qgc2V0IG5lZWRzX3JlbW90ZV93YWtldXAg
aW4gcHJvYmUoKSwgYnV0IHlvdQ0KPiBtdXN0IHNldCBpdCBpbiBvcGVuKCkgYmVjYXVzZSBpdCBp
cyBuZWNlc3NhcnkgZm9yIHJ1bnRpbWUgcG93ZXIgbWFuYWdlbWVudCBhcyBJDQo+IGV4cGxhaW5l
ZCBhYm92ZS4NCj4gDQo+IFNvcnJ5IGZvciB0aGUgbGVuZ3RoIG9mIHRoaXMgbWFpbCwgYnV0IEkg
d2FudGVkIHRvIG1ha2Ugc3VyZSBJIGFtIGFic29sdXRlbHkgY2xlYXINCj4gdGhpcyB0aW1lLg0K
DQpUaGFua3MgZm9yIHlvdSBleHBsYW5hdGlvbi4gSSBmb2N1cyBvbiB0aGUgd3JvbmcgcG9pbnQu
IFlvdSBtZWFuIHRoaXMgd291bGQgY2F1c2UNCnRoZSBwcm9ibGVtIGZvciBydW50aW1lIHN1c3Bl
bmQuIEkgd291bGQgcmV0aGluayBteSBtZXRob2QgYW5kIGNvcnJlY3QgaXQuDQoNCkJlc3QgUmVn
YXJkcywNCkhheWVzDQoNCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
