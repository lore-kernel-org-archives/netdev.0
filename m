From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: RE: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for
 T4240-R1.0-R2.0
Date: Thu, 26 May 2016 04:05:26 +0000
Message-ID: <HE1PR04MB0889852B7809A1CCFF8922ACF8410@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <4448030.Zs8fVnr3nm@wuerfel>
	 <HE1PR04MB0889B52134A43C0E7A452B7BF87C0@HE1PR04MB0889.eurprd04.prod.outlook.com>
	 <5159406.HOFrj7pRfW@wuerfel> <1462937186.16584.77.camel@buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"Mark Rutland" <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	"Bhupesh Sharma" <bhupesh.sharma@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joerg Roedel <joro@8bytes.org>,
	Kumar Gala <galak@codeaurora.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"Rob Herring" <robh+dt@kernel.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <q
To: "ulf.hansson@linaro.org" <ulf.hansson@linaro.org>,
	Scott Wood <oss@buserror.net>, Arnd Bergmann <arnd@arndb.de>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-i2c-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-i2c-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgVWZmZSwNCg0KQ291bGQgd2UgbWVyZ2UgdGhpcyBwYXRjaHNldD8gLi4uDQpJdCBoYXMgYmVl
biBhIGxvbmcgdGltZSB0byB3YWl0IGZvciBBcm5kJ3MgcmVzcG9uc2UuLi4NCiANClRoYW5rcyBh
IGxvdC4NCg0KDQpCZXN0IHJlZ2FyZHMsDQpZYW5nYm8gTHUNCg0KDQo+IC0tLS0tT3JpZ2luYWwg
TWVzc2FnZS0tLS0tDQo+IEZyb206IFlhbmdibyBMdQ0KPiBTZW50OiBGcmlkYXksIE1heSAyMCwg
MjAxNiAyOjA2IFBNDQo+IFRvOiAnU2NvdHQgV29vZCc7IEFybmQgQmVyZ21hbm47IGxpbnV4LWFy
bS1rZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZw0KPiBDYzogbGludXhwcGMtZGV2QGxpc3RzLm96
bGFicy5vcmc7IE1hcmsgUnV0bGFuZDsNCj4gZGV2aWNldHJlZUB2Z2VyLmtlcm5lbC5vcmc7IHVs
Zi5oYW5zc29uQGxpbmFyby5vcmc7IFJ1c3NlbGwgS2luZzsgQmh1cGVzaA0KPiBTaGFybWE7IG5l
dGRldkB2Z2VyLmtlcm5lbC5vcmc7IEpvZXJnIFJvZWRlbDsgS3VtYXIgR2FsYTsgbGludXgtDQo+
IG1tY0B2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7IFlhbmct
TGVvIExpOw0KPiBpb21tdUBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZzsgUm9iIEhlcnJpbmc7
IGxpbnV4LWkyY0B2Z2VyLmtlcm5lbC5vcmc7DQo+IENsYXVkaXUgTWFub2lsOyBTYW50b3NoIFNo
aWxpbWthcjsgWGlhb2JvIFhpZTsgbGludXgtY2xrQHZnZXIua2VybmVsLm9yZzsNCj4gUWlhbmcg
Wmhhbw0KPiBTdWJqZWN0OiBSRTogW3YxMCwgNy83XSBtbWM6IHNkaGNpLW9mLWVzZGhjOiBmaXgg
aG9zdCB2ZXJzaW9uIGZvciBUNDI0MC0NCj4gUjEuMC1SMi4wDQo+IA0KPiBIaSBBcm5kLA0KPiAN
Cj4gQW55IGNvbW1lbnRzPw0KPiBQbGVhc2UgcmVwbHkgd2hlbiB5b3Ugc2VlIHRoZSBlbWFpbCBz
aW5jZSB3ZSB3YW50IHRoaXMgZVNESEMgaXNzdWUgdG8gYmUNCj4gZml4ZWQgc29vbi4NCj4gDQo+
IEFsbCB0aGUgcGF0Y2hlcyBhcmUgRnJlZXNjYWxlLXNwZWNpZmljIGFuZCBpcyB0byBmaXggdGhl
IGVTREhDIGRyaXZlci4NCj4gQ291bGQgd2UgbGV0IHRoZW0gbWVyZ2VkIGZpcnN0IGlmIHlvdSB3
ZXJlIHRhbGtpbmcgYWJvdXQgYSBuZXcgd2F5IG9mDQo+IGFic3RyYWN0aW5nIGdldHRpbmcgU29D
IHZlcnNpb24uDQo+IA0KPiANCj4gVGhhbmtzIDopDQo+IA0KPiANCj4gQmVzdCByZWdhcmRzLA0K
PiBZYW5nYm8gTHUNCj4gDQoNCg==
