From: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [PATCH 2/4] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 8 Jul 2016 03:05:41 +0000
Message-ID: <HE1PR04MB0889950E99B791029F1670E9F83C0@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<1465609853.22191.151.camel@buserror.net>
	<HE1PR04MB0889646206BFAD68046F3473F83B0@HE1PR04MB0889.eurprd04.prod.outlook.com>
	<4094106.qfxJu3tJbO@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Ulf
	Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu@l
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4094106.qfxJu3tJbO@wuerfel>
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

SGkgQXJuZCwNCg0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IEFybmQg
QmVyZ21hbm4gW21haWx0bzphcm5kQGFybmRiLmRlXQ0KPiBTZW50OiBUaHVyc2RheSwgSnVseSAw
NywgMjAxNiA0OjMwIFBNDQo+IFRvOiBZYW5nYm8gTHUNCj4gQ2M6IFNjb3R0IFdvb2Q7IGxpbnV4
cHBjLWRldkBsaXN0cy5vemxhYnMub3JnOyBNYXJrIFJ1dGxhbmQ7IFVsZiBIYW5zc29uOw0KPiBs
aW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBsaW51eC1pMmNAdmdlci5rZXJuZWwub3JnOyBs
aW51eC0NCj4gY2xrQHZnZXIua2VybmVsLm9yZzsgUWlhbmcgWmhhbzsgUnVzc2VsbCBLaW5nOyBC
aHVwZXNoIFNoYXJtYTsgSm9lcmcNCj4gUm9lZGVsOyBDbGF1ZGl1IE1hbm9pbDsgZGV2aWNldHJl
ZUB2Z2VyLmtlcm5lbC5vcmc7IEt1bWFyIEdhbGE7IFJvYg0KPiBIZXJyaW5nOyBTYW50b3NoIFNo
aWxpbWthcjsgbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnOw0KPiBuZXRkZXZA
dmdlci5rZXJuZWwub3JnOyBsaW51eC1tbWNAdmdlci5rZXJuZWwub3JnOyBYaWFvYm8gWGllOyBZ
YW5nLUxlbw0KPiBMaTsgaW9tbXVAbGlzdHMubGludXgtZm91bmRhdGlvbi5vcmcNCj4gU3ViamVj
dDogUmU6IFtQQVRDSCAyLzRdIHNvYzogZnNsOiBhZGQgR1VUUyBkcml2ZXIgZm9yIFFvcklRIHBs
YXRmb3Jtcw0KPiANCj4gT24gVGh1cnNkYXksIEp1bHkgNywgMjAxNiAyOjM1OjMzIEFNIENFU1Qg
WWFuZ2JvIEx1IHdyb3RlOg0KPiA+IEhpIEFybmQsDQo+ID4NCj4gPiBDb3VsZCB5b3UgcmVwbHkg
d2hlbiB5b3Ugc2VlIHRoZSBlbWFpbD8NCj4gPiBJZiB5b3VyIG1ldGhvZCBkb2VzbuKAmXQgcmVz
b2x2ZSB0aGUgcHJvYmxlbSwgd2Ugc3RpbGwgd2FudCB0byB1c2Ugb3VyDQo+IG9sZCBwYXRjaHNl
dC4NCj4gPg0KPiA+IFRoaXMgZ3V0cyBkcml2ZXIgaGFkIGJlZW4gZGlzY3Vzc2VkIGFib3V0IG9u
ZSB5ZWFyIGFuZCBibG9ja2VkIG1hbnkNCj4gd29ya2Fyb3VuZCB1cHN0cmVhbS4NCj4gPiBTbyBw
bGVhc2UgaGVscCB0byByZXZpZXcgYW5kIGNvbW1lbnQgc29vbi4NCj4gPg0KPiANCj4gSSBkb24n
dCByZWFsbHkgc2VlIGhvdyBtb3JlIGRpc2N1c3Npb24gaXMgZ29pbmcgdG8gaGVscCB1cyBoZXJl
LiBJIHRoaW5rDQo+IEkndmUgbWFkZSBpdCBwcmV0dHkgY2xlYXIgdGhhdCBJIGRvbid0IHdhbnQg
dG8gc2VlIGFub3RoZXIgcGxhdGZvcm0NCj4gc3BlY2lmaWMgd2F5IHRvIHJlYWQgYW4gU29DIHJl
dmlzaW9uIGFuZCBJJ3ZlIGV2ZW4gc2VudCBhIHByb29mLW9mLQ0KPiBjb25jZXB0IHBhdGNoIHRv
IHNob3cgaG93IHRoZSBpbnRlcmZhY2UgY2FuIHdvcmssIG5vdyBpdCdzIHVwIHRvIHlvdSB0bw0K
PiBmaXQgdGhlIGd1dHMgaGFyZHdhcmUgaW50byB0aGF0IGFuZCBzZW5kIGEgbmV3IHBhdGNoIHNl
cmllcy4NCj4gDQo+IAlBcm5kDQoNCkkgdGhpbmsgeW91ciBwcm9vZi1vZi1jb25jZXB0IHBhdGNo
IGlzIHN0aWxsIGluIGRpc2N1c3Npb24uIFNvbWUgYW5zd2VycyBhcmUgbmVlZGVkIGZyb20geW91
IHRvDQphZGRyZXNzIFNjb3R0J3MgY29tbWVudHMgb24geW91ciBwYXRjaHNldC4gSGF2ZSB5b3Ug
cmVhY2hlZCBhbiBhZ3JlZW1lbnQ/DQoNClRoYW5rcy4NCg0KLSBZYW5nYm8gTHUNCg0KDQoNCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmlvbW11IG1haWxp
bmcgbGlzdAppb21tdUBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxp
bnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9pb21tdQ==
