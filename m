From: Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [PATCH] [net-next] net/mlx5: include wq.o in non-ethernet build
 for FPGA
Date: Fri, 30 Jun 2017 18:58:16 +0000
Message-ID: <AM4PR0501MB19409232F4E056237F2FAFFFDBD30@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170630154412.3575760-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Boris Pismenny <borisp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Hadar Hen Zion <hadarh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Kamal Heib <kamalh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mohamad Haj Yahia <mohamad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Aviv Heller <avivh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "Matan Barak" <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170630154412.3575760-1-arnd-r2nGTMty4D4@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBcm5kIEJlcmdtYW5uIFttYWls
dG86YXJuZEBhcm5kYi5kZV0NCj4gU3ViamVjdDogW1BBVENIXSBbbmV0LW5leHRdIG5ldC9tbHg1
OiBpbmNsdWRlIHdxLm8gaW4gbm9uLWV0aGVybmV0IGJ1aWxkDQo+IGZvciBGUEdBDQo+IA0KPiBC
b3RoIHRoZSBldGhlcm5ldCBhbmQgRlBHQSBwb3J0aW9ucyBvZiBNTFg1IG5vdyByZXF1aXJlIHRo
ZSB3cSBmdW5jdGlvbnMsDQo+IGFuZCB3ZSBnZXQgYSBsaW5rIGVycm9yIHdoZW4gQ09ORklHX01M
WDVfQ09SRV9FTiBpcyBkaXNhYmxlZDoNCj4gDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxh
bm94L21seDUvY29yZS9mcGdhL2Nvbm4ubzogSW4gZnVuY3Rpb24NCj4gYG1seDVfZnBnYV9jb25u
X2NyZWF0ZV9jcSc6DQo+IGNvbm4uYzooLnRleHQrMHgxMGIzKTogdW5kZWZpbmVkIHJlZmVyZW5j
ZSB0byBgbWx4NV9jcXdxX2NyZWF0ZScNCj4gY29ubi5jOigudGV4dCsweDEwYzYpOiB1bmRlZmlu
ZWQgcmVmZXJlbmNlIHRvIGBtbHg1X2Nxd3FfZ2V0X3NpemUnDQo+IGNvbm4uYzooLnRleHQrMHgx
MmJjKTogdW5kZWZpbmVkIHJlZmVyZW5jZSB0byBgbWx4NV9jcXdxX2Rlc3Ryb3knDQo+IA0KPiBU
aGlzIGluY2x1ZGVzIHRoZSBsaWJyYXJ5IGluIHRoZSBjb3JlIGRyaXZlciBhbHNvIHdoZW4gb25s
eSB0aGUgZnBnYQ0KPiBzdXBwb3J0IGlzIGVuYWJsZWQuDQo+IA0KPiBGaXhlczogNTM3YTUwNTc0
MTc1ICgibmV0L21seDU6IEZQR0EsIEFkZCBoaWdoLXNwZWVkIGNvbm5lY3Rpb24gcm91dGluZXMi
KQ0KPiBTaWduZWQtb2ZmLWJ5OiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPg0KPiAtLS0N
Cj4gIGRyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUvY29yZS9NYWtlZmlsZSB8IDIg
Ky0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPiAN
Cj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUvY29yZS9N
YWtlZmlsZQ0KPiBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUvY29yZS9NYWtl
ZmlsZQ0KPiBpbmRleCBjYTM2NzQ0NWY4NjQuLjUwZmU5ZTNjNWRjMiAxMDA2NDQNCj4gLS0tIGEv
ZHJpdmVycy9uZXQvZXRoZXJuZXQvbWVsbGFub3gvbWx4NS9jb3JlL01ha2VmaWxlDQo+ICsrKyBi
L2RyaXZlcnMvbmV0L2V0aGVybmV0L21lbGxhbm94L21seDUvY29yZS9NYWtlZmlsZQ0KPiBAQCAt
OSw3ICs5LDcgQEAgbWx4NV9jb3JlLXkgOj0JbWFpbi5vIGNtZC5vIGRlYnVnZnMubyBmdy5vIGVx
Lm8gdWFyLm8NCj4gcGFnZWFsbG9jLm8gXA0KPiAgbWx4NV9jb3JlLSQoQ09ORklHX01MWDVfQUND
RUwpICs9IGFjY2VsL2lwc2VjLm8NCj4gDQo+ICBtbHg1X2NvcmUtJChDT05GSUdfTUxYNV9GUEdB
KSArPSBmcGdhL2NtZC5vIGZwZ2EvY29yZS5vIGZwZ2EvY29ubi5vDQo+IGZwZ2Evc2RrLm8gXA0K
PiAtCQlmcGdhL2lwc2VjLm8NCj4gKwkJZnBnYS9pcHNlYy5vIHdxLm8NCg0KSSBiZWxpZXZlIHdl
IHdvdWxkIHByZWZlciB0byBtb3ZlIHdxLm8gdG8gbWx4NV9jb3JlLXkuDQpPdGhlcndpc2UgeW91
IG1pZ2h0IGJ1aWxkIGl0IHR3aWNlLg0KDQo+IA0KPiAgbWx4NV9jb3JlLSQoQ09ORklHX01MWDVf
Q09SRV9FTikgKz0gd3EubyBlc3dpdGNoLm8gZXN3aXRjaF9vZmZsb2Fkcy5vIFwNCj4gIAkJZW5f
bWFpbi5vIGVuX2NvbW1vbi5vIGVuX2ZzLm8gZW5fZXRodG9vbC5vIGVuX3R4Lm8gXA0KPiAtLQ0K
PiAyLjkuMA0KDQo=
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
