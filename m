From: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH v3.5 17/19] mwifiex: slight optimization of addr compare
Date: Tue, 7 Jan 2014 18:50:28 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430F534B5541@SC-VEXCH1.marvell.com>
References: <52BC15E7.7050205@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52BC15E7.7050205-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

SGkgRGluZywNCg0KPiBVc2UgcG9zc2libHkgbW9yZSBlZmZpY2llbnQgZXRoZXJfYWRkcl9lcXVh
bA0KPiBpbnN0ZWFkIG9mIG1lbWNtcC4NCg0KPiBAQCAtNzgyLDggKzc4Miw3IEBAIHN0YXRpYyBp
bnQgbXdpZmlleF9yZXRfaWJzc19jb2FsZXNjaW5nX3N0YXR1cyhzdHJ1Y3QgbXdpZmlleF9wcml2
YXRlICpwcml2LA0KPiAgCX0NCj4gDQo+ICAJLyogSWYgQlNTSUQgaXMgZGlmZiwgbW9kaWZ5IGN1
cnJlbnQgQlNTIHBhcmFtZXRlcnMgKi8NCj4gLQlpZiAobWVtY21wKHByaXYtPmN1cnJfYnNzX3Bh
cmFtcy5ic3NfZGVzY3JpcHRvci5tYWNfYWRkcmVzcywNCj4gLQkJICAgaWJzc19jb2FsX3Jlc3At
PmJzc2lkLCBFVEhfQUxFTikpIHsNCj4gKwlpZiAoIWV0aGVyX2FkZHJfZXF1YWwocHJpdi0+Y3Vy
cl9ic3NfcGFyYW1zLmJzc19kZXNjcmlwdG9yLm1hY19hZGRyZXNzLCBpYnNzX2NvYWxfcmVzcC0+
YnNzaWQpKQ0KDQpDb3VsZCB5b3UgYnJlYWsgdGhlIGxpbmU/DQpJZiB5b3UgcnVuICJjaGVja3Bh
dGNoLnBsIiB5b3Ugd2lsbCBzcG90IHRoaXMgd2FybmluZy4NCg0KPiAgCWlmICghSVNfMTFOX0VO
QUJMRUQocHJpdikgfHwNCj4gLQkgICAgbWVtY21wKHByaXYtPmN1cnJfYWRkciwgcnhfcGt0X2hk
ci0+ZXRoODAzX2hkci5oX2Rlc3QsIEVUSF9BTEVOKSkgew0KPiArCSAgICAhZXRoZXJfYWRkcl9l
cXVhbF91bmFsaWduZWQocHJpdi0+Y3Vycl9hZGRyLCByeF9wa3RfaGRyLT5ldGg4MDNfaGRyLmhf
ZGVzdCkpIHsNCg0KQWxzbyBvdmVyIDgwIGNoYXJhY3RlcnMgaGVyZS4NCg0KVGhhbmtzLA0KQmlu
Zw0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
