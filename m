From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 2/4] soc: fsl: add GUTS driver for QorIQ platforms
Date: Thu, 07 Jul 2016 10:30:29 +0200
Message-ID: <4094106.qfxJu3tJbO@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<1465609853.22191.151.camel@buserror.net>
	<HE1PR04MB0889646206BFAD68046F3473F83B0@HE1PR04MB0889.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
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
	Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>, "iommu-cunTk1MwBs+mg8Ev75riOw@public.gmane.org
	x-foundation.org" <iommu@
To: Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <HE1PR04MB0889646206BFAD68046F3473F83B0-6LN7OEpIatX1kPMWxTxe+c9NdZoXdze2vxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
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

T24gVGh1cnNkYXksIEp1bHkgNywgMjAxNiAyOjM1OjMzIEFNIENFU1QgWWFuZ2JvIEx1IHdyb3Rl
Ogo+IEhpIEFybmQsCj4gCj4gQ291bGQgeW91IHJlcGx5IHdoZW4geW91IHNlZSB0aGUgZW1haWw/
Cj4gSWYgeW91ciBtZXRob2QgZG9lc27igJl0IHJlc29sdmUgdGhlIHByb2JsZW0sIHdlIHN0aWxs
IHdhbnQgdG8gdXNlIG91ciBvbGQgcGF0Y2hzZXQuCj4gCj4gVGhpcyBndXRzIGRyaXZlciBoYWQg
YmVlbiBkaXNjdXNzZWQgYWJvdXQgb25lIHllYXIgYW5kIGJsb2NrZWQgbWFueSB3b3JrYXJvdW5k
IHVwc3RyZWFtLgo+IFNvIHBsZWFzZSBoZWxwIHRvIHJldmlldyBhbmQgY29tbWVudCBzb29uLgo+
IAoKSSBkb24ndCByZWFsbHkgc2VlIGhvdyBtb3JlIGRpc2N1c3Npb24gaXMgZ29pbmcgdG8gaGVs
cCB1cyBoZXJlLiBJIHRoaW5rCkkndmUgbWFkZSBpdCBwcmV0dHkgY2xlYXIgdGhhdCBJIGRvbid0
IHdhbnQgdG8gc2VlIGFub3RoZXIgcGxhdGZvcm0Kc3BlY2lmaWMgd2F5IHRvIHJlYWQgYW4gU29D
IHJldmlzaW9uIGFuZCBJJ3ZlIGV2ZW4gc2VudCBhIHByb29mLW9mLWNvbmNlcHQKcGF0Y2ggdG8g
c2hvdyBob3cgdGhlIGludGVyZmFjZSBjYW4gd29yaywgbm93IGl0J3MgdXAgdG8geW91IHRvIGZp
dCB0aGUKZ3V0cyBoYXJkd2FyZSBpbnRvIHRoYXQgYW5kIHNlbmQgYSBuZXcgcGF0Y2ggc2VyaWVz
LgoKCUFybmQKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
CmlvbW11IG1haWxpbmcgbGlzdAppb21tdUBsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZwpodHRw
czovL2xpc3RzLmxpbnV4Zm91bmRhdGlvbi5vcmcvbWFpbG1hbi9saXN0aW5mby9pb21tdQ==
