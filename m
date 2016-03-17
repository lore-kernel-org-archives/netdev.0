From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [v6,
	5/5] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Thu, 17 Mar 2016 18:06:09 +0100
Message-ID: <3706958.XeRFmKM0K5@wuerfel>
References: <1457518131-11339-1-git-send-email-yangbo.lu@nxp.com>
	<DB5PR0401MB19286B2D23D07F5C60DB799D91880@DB5PR0401MB1928.eurprd04.prod.outlook.com>
	<20160317170101.GA21009@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Zhao Qiang <qiang.zhao-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Scott Wood <scott.wood-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>, Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160317170101.GA21009@rob-hp-laptop>
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

T24gVGh1cnNkYXkgMTcgTWFyY2ggMjAxNiAxMjowMTowMSBSb2IgSGVycmluZyB3cm90ZToKPiBP
biBNb24sIE1hciAxNCwgMjAxNiBhdCAwNTo0NTo0M1BNICswMDAwLCBTY290dCBXb29kIHdyb3Rl
OgoKPiA+ID4+IFRoaXMgbWFrZXMgdGhlIGRyaXZlciBub24tcG9ydGFibGUuIEJldHRlciBpZGVu
dGlmeSB0aGUgc3BlY2lmaWMKPiA+ID4+IHdvcmthcm91bmRzIGJhc2VkIG9uIHRoZSBjb21wYXRp
YmxlIHN0cmluZyBmb3IgdGhpcyBkZXZpY2UsIG9yIGFkZCBhCj4gPiA+PiBib29sZWFuIERUIHBy
b3BlcnR5IGZvciB0aGUgcXVpcmsuCj4gPiA+Pgo+ID4gPj4gICAgQXJuZAo+ID4gPiAKPiA+ID4g
W0x1IFlhbmdiby1CNDcwOTNdIEhpIEFybmQsIHdlIGRpZCBoYXZlIGEgZGlzY3Vzc2lvbiBhYm91
dCB1c2luZyBEVFMgaW4gdjEgYmVmb3JlLgo+ID4gPiBodHRwczovL3BhdGNod29yay5rZXJuZWwu
b3JnL3BhdGNoLzY4MzQyMjEvCj4gPiA+IAo+ID4gPiBXZSBkb27igJl0IGhhdmUgYSBzZXBhcmF0
ZSBEVFMgZmlsZSBmb3IgZWFjaCByZXZpc2lvbiBvZiBhbiBTT0MgYW5kIGlmIHdlIGRpZCwgd2Un
ZCBjb25zdGFudGx5IGhhdmUgcGVvcGxlIHVzaW5nIHRoZSB3cm9uZyBvbmUuCj4gPiA+IEluIGFk
ZGl0aW9uLCB0aGUgZGV2aWNlIHRyZWUgaXMgc3RhYmxlIEFCSSBhbmQgZXJyYXRhIGFyZSBvZnRl
biBkaXNjb3ZlcmVkIGFmdGVyIGRldmljZSB0cmVlIGFyZSBkZXBsb3llZC4KPiA+ID4gU2VlIHRo
ZSBsaW5rIGZvciBkZXRhaWxzLgo+ID4gPiAKPiA+ID4gU28gd2UgZGVjaWRlIHRvIHJlYWQgU1ZS
IGZyb20gdGhlIGRldmljZS1jb25maWcvZ3V0cyBNTUlPIGJsb2NrIG90aGVyIHRoYW4gdXNpbmcg
RFRTLgo+ID4gPiBUaGFua3MuCj4gPiAKPiA+IEFsc28gbm90ZSB0aGF0IHRoaXMgZHJpdmVyIGlz
IGFscmVhZHkgb25seSBmb3IgZnNsLXNwZWNpZmljIGhhcmR3YXJlLAo+ID4gYW5kIGl0IHdpbGwg
c3RpbGwgd29yayBldmVuIGlmIGZzbF9ndXRzIGRvZXNuJ3QgZmluZCBhbnl0aGluZyB0byBiaW5k
IHRvCj4gPiAtLSBpdCBqdXN0IHdvdWxkbid0IGJlIGFibGUgdG8gZGV0ZWN0IGVycmF0YSBiYXNl
ZCBvbiBTVlIgaW4gdGhhdCBjYXNlLgo+IAo+IElJUkMsIGl0IGlzIHRoZSBzYW1lIElQIGJsb2Nr
IGFzIGkuTVggYW5kIEFybmQncyBwb2ludCBpcyB0aGlzIHdvbid0IAo+IGV2ZW4gY29tcGlsZSBv
biAhUFBDLiBJdCBpcyB0aGluZ3MgbGlrZSB0aGlzIHRoYXQgcHJldmVudCBzaGFyaW5nIHRoZSAK
PiBkcml2ZXIuCgpJIHRoaW5rIHRoZSBmaXJzdCBmb3VyIHBhdGNoZXMgdGFrZSBjYXJlIG9mIGJ1
aWxkaW5nIGZvciBBUk0sCmJ1dCB0aGUgcHJvYmxlbSByZW1haW5zIGlmIHlvdSB3YW50IHRvIGVu
YWJsZSBDT01QSUxFX1RFU1QgYXMKd2UgbmVlZCBmb3IgY2VydGFpbiBhdXRvbWF0ZWQgY2hlY2tp
bmcuCgo+IERlYWxpbmcgd2l0aCBTaSByZXZzIGlzIGEgY29tbW9uIHByb2JsZW0uIFdlIHNob3Vs
ZCBoYXZlIGEgCj4gY29tbW9uIHNvbHV0aW9uLiBUaGVyZSBpcyBzb2NfZGV2aWNlIGZvciB0aGlz
IHB1cnBvc2UuCgpFeGFjdGx5LiBUaGUgbGFzdCB0aW1lIHRoaXMgY2FtZSB1cCwgSSB0aGluayB3
ZSBhZ3JlZWQgdG8gaW1wbGVtZW50IGEKaGVscGVyIHVzaW5nIGdsb2JfbWF0Y2goKSBvbiB0aGUg
c29jX2RldmljZSBzdHJpbmdzLiBVbmZvcnR1bmF0ZWx5CnRoaXMgaGFzbid0IGhhcHBlbmVkIHRo
ZW4sIGJ1dCBJJ2Qgc3RpbGwgcHJlZmVyIHRoYXQgb3ZlciB5ZXQgYW5vdGhlcgp2ZW5kb3Itc3Bl
Y2lmaWMgd2F5IG9mIGRlYWxpbmcgd2l0aCB0aGUgZ2VuZXJpYyBpc3N1ZS4KCglBcm5kCl9fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmlvbW11IG1haWxpbmcg
bGlzdAppb21tdUBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRwczovL2xpc3RzLmxpbnV4
Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9pb21tdQ==
