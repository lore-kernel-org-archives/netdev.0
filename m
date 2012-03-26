From: "Bounine, Alexandre" <Alexandre.Bounine@idt.com>
Subject: RE: [PATCH linux-next] dmaengine: add context parameter fixups
Date: Mon, 26 Mar 2012 13:14:09 +0000
Message-ID: <8D983423E7EDF846BB3056827B8CC5D101384B@corpmail1.na.ads.idt.com>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	 <CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
	 <1332740082.19804.15.camel@vkoul-udesk3>
	 <20120326094200.GA3098@opensource.wolfsonmicro.com>
 <1332755670.19804.91.camel@vkoul-udesk3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Fabio Estevam <festevam@gmail.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"samuel@sortiz.org" <samuel@sortiz.org>, "lrg@ti.com" <lrg@ti.com>,
	"perex@perex.cz" <perex@perex.cz>, "tiwai@suse.de" <tiwai@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"alsa-devel@alsa-project.org" <alsa-devel@alsa-project.org>
To: Vinod Koul <vinod.koul@linux.intel.com>,
	Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332755670.19804.91.camel@vkoul-udesk3>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

T24gTW9uLCBNYXJjaCAyNiwgMjAxMiBhdCA1OjU1IEFNLCBWaW5vZCBLb3VsIHdyb3RlOg0KPiBT
dWJqZWN0OiBSZTogW1BBVENIIGxpbnV4LW5leHRdIGRtYWVuZ2luZTogYWRkIGNvbnRleHQgcGFy
YW1ldGVyIGZpeHVwcw0KPiANCj4gT24gTW9uLCAyMDEyLTAzLTI2IGF0IDEwOjQyICswMTAwLCBN
YXJrIEJyb3duIHdyb3RlOg0KPiA+IE9uIE1vbiwgTWFyIDI2LCAyMDEyIGF0IDExOjA0OjQyQU0g
KzA1MzAsIFZpbm9kIEtvdWwgd3JvdGU6DQo+ID4gPiBPbiBTYXQsIDIwMTItMDMtMjQgYXQgMTI6
MjMgLTAzMDAsIEZhYmlvIEVzdGV2YW0gd3JvdGU6DQo+ID4NCj4gPiA+ID4gaHR0cDovL3Blcm1h
bGluay5nbWFuZS5vcmcvZ21hbmUubGludXguYWxzYS5kZXZlbC85NjIxNQ0KPiA+DQo+ID4gPiBB
bmQgdGhpcyBzZWVtcyB0byBiZSBsaW51eC1uZXh0Lg0KPiA+DQo+ID4gPiBNYXJrLCBJcyB0aGlz
IHBhcnQgb2YgdGhlIHNvdW5kIHVwZGF0ZXMgdGhhdCB3ZW50IHRvIExpbnVzPw0KPiA+DQo+ID4g
Tm8sIG5vdCB5ZXQgLSBpdCB3YXMgb25seSBzZW50IGFmdGVyIHRoZSBtZXJnZSB3aW5kb3cuICBR
dWl0ZSB3aHkNCj4gbm9ib2R5DQo+ID4gbWFuYWdlZCB0byBub3RpY2UgaXQgYmVmb3JlIHRoZW4g
SSBkb24ndCBrbm93LiAgSXQnbGwgZ28gdG8gaGltIHNvb24sDQo+IG9yDQo+ID4gYXQgbGVhc3Qg
dG8gVGFrYXNoaSwgYnV0IGRvbid0IGtub3cgaWYgaXQnbGwgbWFrZSAtcmMxIG9yIG5vdC4NCj4g
SSBzaG91bGQgaGF2ZSBub3RpY2VkIHRoYXQgc291bmQgbmVlZHMgdXBkYXRlIGFzIHdlbGwgIDoo
DQo+IA0KPiBOb3cgZWl0aGVyIEkgZHJvcCB0aGVzZSBmcm9tIDMuNCBvciBtZXJnZSBMaW51cydz
IHRyZWUgYW5kIGFwcGx5DQo+IEFsZXhhbmRyZSdzIGZpeCAoYXMgdGhhdCBpcyB0aGUgcmlnaHQg
Zml4IHJhdGhlciB0aGFuIG9uZSBpbiBhc29jIHRyZWUpDQo+IEFuZCBzaW5jZSB0aGlzIHdhcyBy
ZXF1aXJlZCBmb3IgUklPIHBhdGNoZXMgd2hpY2ggYXJlIHN0aWxsIFdJUCwgSQ0KPiB0aGluaw0K
PiBJIGFtIGxlYW5pbmcgdG93YXJkcyBmb3JtZXIuDQo+IA0KDQpJIGRvIG5vdCBzZWUgYW55IHNl
bnNlIGluIGRyb3BwaW5nIHRoZXNlIEFQSSBjaGFuZ2VzIG5vdy4NClNvbWUgYXVkaW8gZmlsZXMg
aGF2ZSBiZWVuIG1pc3NlZCBmb3JtIHRoZSBvcmlnaW5hbCBwYXRjaCBiZWNhdXNlIEkgZGlkDQpu
b3QgaGF2ZSB0aGVtIGluIHRoZSBjb2RlIHRyZWUgd2hlbiBwYXRjaCB3YXMgYnVpbHQuDQpGb3Ig
dGhvc2Ugd2hvIHdhcyBub3QgaW4gdGhlIGxpc3QgZm9yIG9yaWdpbmFsIHBhdGNoZXMgaGVyZSBp
cyBhIGxpbmsgdG8NCnRoZSBwYXRjaCBkZXRhaWxzOiBodHRwczovL2xrbWwub3JnL2xrbWwvMjAx
Mi8zLzgvMzczDQoNCklmIHdlIGRyb3AgdGhlIEFQSSBjaGFuZ2VzIG5vdyB3ZSB3aWxsIG5lZWQg
cmVkbyB0aGVzZSBjaGFuZ2VzIGFnYWluIGxhdGVyLg0KV2UgYWxyZWFkeSBkcmFnZ2VkIHRoZXNl
IGNoYW5nZXMgbG9uZyBlbm91Z2ggc2luY2Ugb3JpZ2luYWwgZGlzY3Vzc2lvbiBpbiBPY3RvYmVy
Lg0KSSB3aWxsIHNlbmQgbmV3IGlubGluZSB3cmFwcGVyIGZvciBSYXBpZElPIHRvZGF5LiANCg0K
QWxleC4NCg0KDQo=
