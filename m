From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH][-next] net/mlx5: fix spelling mistake: "Allodating" ->
 "Allocating"
Date: Fri, 30 Jun 2017 18:55:06 +0000
Message-ID: <AM4PR0501MB19407BBB3A184F8A5C743530DBD30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170630105922.10397-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Saeed Mahameed" <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "Leon Romanovsky" <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170630105922.10397-1-colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBDb2xpbiBLaW5nIFttYWlsdG86
Y29saW4ua2luZ0BjYW5vbmljYWwuY29tXQ0KPiBTdWJqZWN0OiBbUEFUQ0hdWy1uZXh0XSBuZXQv
bWx4NTogZml4IHNwZWxsaW5nIG1pc3Rha2U6ICJBbGxvZGF0aW5nIiAtPg0KPiAiQWxsb2NhdGlu
ZyINCj4gDQo+IEZyb206IENvbGluIElhbiBLaW5nIDxjb2xpbi5raW5nQGNhbm9uaWNhbC5jb20+
DQo+IA0KPiBUcml2aWFsIGZpeCB0byBzcGVsbGluZyBtaXN0YWtlIGluIG1seDVfY29yZV9kYmcg
ZGVidWcgbWVzc2FnZQ0KPiANCj4gU2lnbmVkLW9mZi1ieTogQ29saW4gSWFuIEtpbmcgPGNvbGlu
LmtpbmdAY2Fub25pY2FsLmNvbT4NCj4gLS0tDQo+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9tZWxs
YW5veC9tbHg1L2NvcmUvbGliL2dpZC5jIHwgMiArLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDEgaW5z
ZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQv
ZXRoZXJuZXQvbWVsbGFub3gvbWx4NS9jb3JlL2xpYi9naWQuYw0KPiBiL2RyaXZlcnMvbmV0L2V0
aGVybmV0L21lbGxhbm94L21seDUvY29yZS9saWIvZ2lkLmMNCj4gaW5kZXggNGQwZGI0ODFmNmM0
Li5kZTJhZWQ0NGFiODUgMTAwNjQ0DQo+IC0tLSBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxh
bm94L21seDUvY29yZS9saWIvZ2lkLmMNCj4gKysrIGIvZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVs
bGFub3gvbWx4NS9jb3JlL2xpYi9naWQuYw0KPiBAQCAtMTAxLDcgKzEwMSw3IEBAIGludCBtbHg1
X2NvcmVfcmVzZXJ2ZWRfZ2lkX2FsbG9jKHN0cnVjdCBtbHg1X2NvcmVfZGV2DQo+ICpkZXYsIGlu
dCAqZ2lkX2luZGV4KQ0KPiAgCWlmIChpbmRleCA8IDApDQo+ICAJCXJldHVybiBpbmRleDsNCj4g
DQo+IC0JbWx4NV9jb3JlX2RiZyhkZXYsICJBbGxvZGF0aW5nIHJlc2VydmVkIEdJRCAldVxuIiwg
aW5kZXgpOw0KPiArCW1seDVfY29yZV9kYmcoZGV2LCAiQWxsb2NhdGluZyByZXNlcnZlZCBHSUQg
JXVcbiIsIGluZGV4KTsNCj4gIAkqZ2lkX2luZGV4ID0gaW5kZXg7DQo+ICAJcmV0dXJuIDA7DQo+
ICB9DQo+IC0tDQo+IDIuMTEuMA0KDQpUaGFuayB5b3UgQ29saW4gZm9yIHRoZSBmaXguDQoNClJl
dmlld2VkLWJ5OiBJbGFuIFRheWFyaSA8aWxhbnRAbWVsbGFub3guY29tPg0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
