From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH v2] r8152: fix lockup when runtime PM is enabled
Date: Wed, 23 Dec 2015 09:20:25 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2F9547E@RTITMBSV03.realtek.com.tw>
References: <1449573462-28417-1-git-send-email-peter@lekensteyn.nl>
	 <0835B3720019904CB8F7AA43166CEEB2F8DAD9@RTITMBSV03.realtek.com.tw>
	 <20151208143305.GB18728@al>
	 <0835B3720019904CB8F7AA43166CEEB2F94D11@RTITMBSV03.realtek.com.tw>
	 <1450782082.8824.23.camel@suse.com>
	 <0835B3720019904CB8F7AA43166CEEB2F94FFF@RTITMBSV03.realtek.com.tw>
 <1450858813.6437.2.camel@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org" <peter-VTkQYDcBqhK7DlmcbJSQ7g@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450858813.6437.2.camel-l3A5Bk7waGM@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

T2xpdmVyIE5ldWt1bSBbbWFpbHRvOm9uZXVrdW1Ac3VzZS5kZV0NCj4gU2VudDogV2VkbmVzZGF5
LCBEZWNlbWJlciAyMywgMjAxNSA0OjIwIFBNDQpbLi4uXQ0KPiBObywgc3RlcCAoMikgZG9lcyBu
b3QgZXhpc3QuIENhbGxzIHRvIHN1c3BlbmQoKSBhbmQgW3Jlc2V0X11yZXN1bWUoKQ0KPiBhbHdh
eXMgYmFsYW5jZS4gVXN1YWxseSBhIGRyaXZlciBzaG91bGRuJ3QgY2FyZSBhYm91dCBzeXN0ZW0g
c3VzcGVuZC4NCj4gVGhlIHdheSB0aGUgZHJpdmVyIGlzIGN1cnJlbnRseSBjb2RlZCB3aWxsIGFs
c28gZmFpbCBmb3IgUG9ydC1Qb3dlciBPZmYuDQoNCkl0IGlzIGRpZmZlcmVudCB3aXRoIFdpbmRv
d3MuIFRoZSBXaW5kb3dzIHdvdWxkIHJlc3VtZSB0aGUgZGV2aWNlIGJlZm9yZQ0Kc3lzdGVtIHN1
c3BlbmQsIGlmIHRoZSBzeXN0ZW0gc3VzcGVuZCBmb2xsb3dzIHRoZSBhdXRvc3VzcGVuZC4NCg0K
V291bGQgdGhpcyBiZSBhIHByb2JsZW0/IEFmdGVyIHN5c3RlbSBzdXNwZW5kLCB0aGUgZGV2aWNl
IG1heSB3YWtlIHVwDQp0aGUgc3lzdGVtIHdoZW4gcmVjZWl2aW5nIGFueSBwYWNrZXQsIG5vdCBv
bmx5IG1hZ2ljIHBhY2tldC4gVGhlIHdha2UNCmV2ZW50cyBhcmUgZGlmZmVyZW50IGZvciBzeXN0
ZW0gc3VzcGVuZCBhbmQgYXV0b3N1c3BlbmQuIEhvd2V2ZXIsIEkNCmNvdWxkbid0IGNoYW5nZSB0
aGUgd2FrZSBldmVudCwgYmVjYXVzZSB0aGUgYXV0b3N1c3BlbmQgb2NjdXJzIGZpcnN0LA0KYW5k
IHRoZSBzdXNwZW5kKCkgaXMgb25seSBjYWxsZWQgb25jZS4NCg0KQmVzdCBSZWdhcmRzLA0KSGF5
ZXMNCg==
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
