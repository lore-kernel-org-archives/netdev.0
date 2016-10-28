From: "Y.B. Lu" <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v13, 5/8] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 28 Oct 2016 06:00:03 +0000
Message-ID: <DB6PR0401MB2536E2CE7B604554F52AF3AFF8AD0@DB6PR0401MB2536.eurprd04.prod.outlook.com>
References: <1477625554-46700-1-git-send-email-yangbo.lu@nxp.com>
	<1477625554-46700-6-git-send-email-yangbo.lu@nxp.com>
	<1477629956.6812.15.camel@buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"X.B. Xie" <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>, "M.H. Lian" <minghuan.lian-3arQi8VN3Tc@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs+mg8Ev75riOw@public.gmane.org
To: Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, "linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org"
	<linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org"
	<ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1477629956.6812.15.camel-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogbGludXgtbW1jLW93bmVy
QHZnZXIua2VybmVsLm9yZyBbbWFpbHRvOmxpbnV4LW1tYy0NCj4gb3duZXJAdmdlci5rZXJuZWwu
b3JnXSBPbiBCZWhhbGYgT2YgU2NvdHQgV29vZA0KPiBTZW50OiBGcmlkYXksIE9jdG9iZXIgMjgs
IDIwMTYgMTI6NDYgUE0NCj4gVG86IFkuQi4gTHU7IGxpbnV4LW1tY0B2Z2VyLmtlcm5lbC5vcmc7
IHVsZi5oYW5zc29uQGxpbmFyby5vcmc7IEFybmQNCj4gQmVyZ21hbm4NCj4gQ2M6IGxpbnV4cHBj
LWRldkBsaXN0cy5vemxhYnMub3JnOyBkZXZpY2V0cmVlQHZnZXIua2VybmVsLm9yZzsgbGludXgt
YXJtLQ0KPiBrZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZzsgbGludXgta2VybmVsQHZnZXIua2Vy
bmVsLm9yZzsgbGludXgtDQo+IGNsa0B2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWkyY0B2Z2VyLmtl
cm5lbC5vcmc7IGlvbW11QGxpc3RzLmxpbnV4LQ0KPiBmb3VuZGF0aW9uLm9yZzsgbmV0ZGV2QHZn
ZXIua2VybmVsLm9yZzsgR3JlZyBLcm9haC1IYXJ0bWFuOyBNYXJrIFJ1dGxhbmQ7DQo+IFJvYiBI
ZXJyaW5nOyBSdXNzZWxsIEtpbmc7IEpvY2hlbiBGcmllZHJpY2g7IEpvZXJnIFJvZWRlbDsgQ2xh
dWRpdSBNYW5vaWw7DQo+IEJodXBlc2ggU2hhcm1hOyBRaWFuZyBaaGFvOyBLdW1hciBHYWxhOyBT
YW50b3NoIFNoaWxpbWthcjsgTGVvIExpOyBYLkIuDQo+IFhpZTsgTS5ILiBMaWFuDQo+IFN1Ympl
Y3Q6IFJlOiBbdjEzLCA1LzhdIHNvYzogZnNsOiBhZGQgR1VUUyBkcml2ZXIgZm9yIFFvcklRIHBs
YXRmb3Jtcw0KPiANCj4gT24gRnJpLCAyMDE2LTEwLTI4IGF0IDExOjMyICswODAwLCBZYW5nYm8g
THUgd3JvdGU6DQo+ID4gKwlndXRzLT5yZWdzID0gb2ZfaW9tYXAobnAsIDApOw0KPiA+ICsJaWYg
KCFndXRzLT5yZWdzKQ0KPiA+ICsJCXJldHVybiAtRU5PTUVNOw0KPiA+ICsNCj4gPiArCS8qIFJl
Z2lzdGVyIHNvYyBkZXZpY2UgKi8NCj4gPiArCW1hY2hpbmUgPSBvZl9mbGF0X2R0X2dldF9tYWNo
aW5lX25hbWUoKTsNCj4gPiArCWlmIChtYWNoaW5lKQ0KPiA+ICsJCXNvY19kZXZfYXR0ci5tYWNo
aW5lID0gZGV2bV9rc3RyZHVwKGRldiwgbWFjaGluZSwNCj4gPiBHRlBfS0VSTkVMKTsNCj4gPiAr
DQo+ID4gKwlzdnIgPSBmc2xfZ3V0c19nZXRfc3ZyKCk7DQo+ID4gKwlzb2NfZGllID0gZnNsX3Nv
Y19kaWVfbWF0Y2goc3ZyLCBmc2xfc29jX2RpZSk7DQo+ID4gKwlpZiAoc29jX2RpZSkgew0KPiA+
ICsJCXNvY19kZXZfYXR0ci5mYW1pbHkgPSBkZXZtX2thc3ByaW50ZihkZXYsIEdGUF9LRVJORUws
DQo+ID4gKwkJCQkJCcKgwqDCoMKgwqAiUW9ySVEgJXMiLCBzb2NfZGllLQ0KPiA+ID5kaWUpOw0K
PiA+ICsJfSBlbHNlIHsNCj4gPiArCQlzb2NfZGV2X2F0dHIuZmFtaWx5ID0gZGV2bV9rYXNwcmlu
dGYoZGV2LCBHRlBfS0VSTkVMLA0KPiA+ICJRb3JJUSIpOw0KPiA+ICsJfQ0KPiA+ICsJc29jX2Rl
dl9hdHRyLnNvY19pZCA9IGRldm1fa2FzcHJpbnRmKGRldiwgR0ZQX0tFUk5FTCwNCj4gPiArCQkJ
CQnCoMKgwqDCoMKgInN2cjoweCUwOHgiLCBzdnIpOw0KPiA+ICsJc29jX2Rldl9hdHRyLnJldmlz
aW9uID0gZGV2bV9rYXNwcmludGYoZGV2LCBHRlBfS0VSTkVMLCAiJWQuJWQiLA0KPiA+ICsJCQkJ
CcKgwqDCoMKgwqDCoMKgU1ZSX01BSihzdnIpLCBTVlJfTUlOKHN2cikpOw0KPiA+ICsNCj4gPiAr
CXNvY19kZXYgPSBzb2NfZGV2aWNlX3JlZ2lzdGVyKCZzb2NfZGV2X2F0dHIpOw0KPiA+ICsJaWYg
KElTX0VSUihzb2NfZGV2KSkNCj4gPiArCQlyZXR1cm4gUFRSX0VSUihzb2NfZGV2KTsNCj4gDQo+
IGlvcmVtYXAgbGVha3Mgb24gdGhpcyBlcnJvciBwYXRoLiDCoFVzZSBkZXZtX2lvcmVtYXBfcmVz
b3VyY2UoKS4NCj4gDQoNCltMdSBZYW5nYm8tQjQ3MDkzXSBPay4gSSBoYXZlIGZpeGVkIGl0IGlu
IHYxNC4gVGhhbmtzIDopDQoNCj4gLVNjb3R0DQo+IA0KPiAtLQ0KPiBUbyB1bnN1YnNjcmliZSBm
cm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3JpYmUgbGludXgtbW1jIiBpbg0K
PiB0aGUgYm9keSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZyBNb3Jl
IG1ham9yZG9tbyBpbmZvIGF0DQo+IGh0dHA6Ly92Z2VyLmtlcm5lbC5vcmcvbWFqb3Jkb21vLWlu
Zm8uaHRtbA0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18K
aW9tbXUgbWFpbGluZyBsaXN0CmlvbW11QGxpc3RzLmxpbnV4LWZvdW5kYXRpb24ub3JnCmh0dHBz
Oi8vbGlzdHMubGludXhmb3VuZGF0aW9uLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2lvbW11
