From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net 2/3] r8152: fix remote wakeup
Date: Thu, 23 Jul 2015 09:55:41 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F3AC58@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
	 <1394712342-15778-150-Taiwan-albertk@realtek.com>
 <1437640258.4377.6.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1437640258.4377.6.camel-IBi9RG/b67k@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiBIaSwNCj4gDQo+IHRoaXMgaXMgbW9zdCBsaWtlbHkgd3JvbmcuIFVzYmNvcmUgZG9lcyBjaGVj
ayBmb3IgYSBkZXZpY2UncyBhYmlsaXR5IHRvDQo+IGRvIHJlbW90ZSB3YWtldXAgYW5kIHdpbGwg
YmxvY2sgYSBydW50aW1lIHN1c3BlbmQgaWYgaXQgZGV0ZWN0cyB0aGF0DQo+IGEgcmVtb3RlIHdh
a2V1cCB3b3VsZCBiZSByZXF1aXJlZCBidXQgdGhlIGRldmljZSBjYW5ub3QgZGVsaXZlci4NCj4g
KHN0YXRpYyBpbnQgYXV0b3N1c3BlbmRfY2hlY2soKSkNCj4gDQo+IFNvIGJ5IHJlbW92aW5nIHRo
ZSBmbGFnIGluIHRoZSBwcm9iZSgpIG1ldGhvZCBtZWFucyB0aGF0IGRldmljZXMgd2lsbA0KPiBz
dXNwZW5kIGR1cmluZyBvcGVyYXRpb25zIHdpdGhvdXQgcmVtb3RlIHdha2V1cCByZXF1ZXN0ZWQu
IFRodXMgYW4NCj4gaW5jb21pbmcgcGFja2V0IGNhbm5vdCB3YWtlIHRoZW0gdXAuDQo+IA0KPiBJ
ZiB5b3UgcmVtb3ZlIHNldHRpbmcgdGhlIGZsYWcgb24gcHJvYmUoKSB5b3UgbmVlZCB0byBzZXQg
aXQgYXQgb3BlbigpDQo+IFthbmQgcmVzZXQgb24gY2xvc2UoKV0sIGFzIGRldmljZXMgd2hpY2gg
Y2Fubm90IGRvIHJlbW90ZSB3YWtldXAgbXVzdA0KPiBvbmx5IGJlIHN1c3BlbmRlZCB3aGVuIHRo
ZXkgYXJlIGRvd24uDQoNCkhpLA0KDQpJIGRvbid0IHRoaW5rIEkgdW5kZXJzdGFuZCB5b3VyIGRl
c2NyaXB0aW9uIGNsZWFybHkuIE15IGlkZWEgaXMgdGhhdCBpZiB0aGUNCmRldmljZSBkb2Vzbid0
IHN1cHBvcnQgd2FrZXVwLCB3ZSBkb24ndCBuZWVkIHNldCAiIG5lZWRzX3JlbW90ZV93YWtldXAi
Lg0KV2UgYWxsb3cgdGhlIGRldmljZSBjb3VsZCBiZSBzdXNwZW5kZWQgYW5kIGNvdWxkbid0IGJl
IHdha2VkIHVwIGJ5DQppbmNvbWluZyBwYWNrZXQuIFRoZSBzeXN0ZW0gY291bGQgYmUgd2FrZWQg
dXAgYnkgb3RoZXIgbWV0aG9kcyBleGNlcHQNCmJ5IHRoZSBkZXZpY2UuDQoNCkkgZG9uJ3QgdW5k
ZXJzdGFuZCB3aHkgSSBoYXZlIHRvIHNldCBpdCBhdCBvcGVuKCkgYW5kIHJlc2V0IGl0IGF0IGNs
b3NlKCkuIEFuZA0Kd2h5IG11c3QgdGhlIGRldmljZSBvbmx5IGJlIHN1c3BlbmRlZCB3aGVuIGl0
IGlzIGRvd24/DQoNCkJlc3QgUmVnYXJkcywNCkhheWVzDQoNCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
