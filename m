From: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>
Subject: RE: [PATCH] moxa: fix the error handling in moxart_mac_probe()
Date: Tue, 8 Oct 2013 03:29:07 +0000
Message-ID: <A360F954C61C69449463B060666371128EB376B4@CDCEXMBX02.tw.trendnet.org>
References: <CAPgLHd95Rv=sCCWFsuLwtGz5GL5+7N-y6zQ195uOXF3ebgcj3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"rob.herring@calxeda.com" <rob.herring@calxeda.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jg1.han@samsung.com" <jg1.han@samsung.com>,
	"b.zolnierkie@samsung.com" <b.zolnierkie@samsung.com>,
	"kyungmin.park@samsung.com" <kyungmin.park@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sjdciscan04.udc.trendmicro.com ([66.180.85.17]:35771 "EHLO
	sjdciscan04.udc.trendmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751485Ab3JHDrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 23:47:21 -0400
In-Reply-To: <CAPgLHd95Rv=sCCWFsuLwtGz5GL5+7N-y6zQ195uOXF3ebgcj3A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

U29ycnksIHRoaXMgbWFpbCBpcyBkdXAgYnkgbWFpbCBzZXJ2ZXIsIHBsZWFzZSBpZ25vcmUgaXQs
IHRoYW5rcy4NCg0KLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IFdlaSBZb25nanVu
IFttYWlsdG86d2VpeWoubGtAZ21haWwuY29tXSANClNlbnQ6IDIwMTPE6jEw1MI4yNUgMTE6MjcN
ClRvOiBncmFudC5saWtlbHlAbGluYXJvLm9yZzsgcm9iLmhlcnJpbmdAY2FseGVkYS5jb207IGRh
dmVtQGRhdmVtbG9mdC5uZXQ7IGpnMS5oYW5Ac2Ftc3VuZy5jb207IGIuem9sbmllcmtpZUBzYW1z
dW5nLmNvbTsga3l1bmdtaW4ucGFya0BzYW1zdW5nLmNvbQ0KQ2M6IFlvbmdqdW4gV2VpIChSRC1D
Tik7IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmcNClN1YmplY3Q6IFtQQVRDSF0gbW94YTogZml4IHRo
ZSBlcnJvciBoYW5kbGluZyBpbiBtb3hhcnRfbWFjX3Byb2JlKCkNCg0KRnJvbTogV2VpIFlvbmdq
dW4gPHlvbmdqdW5fd2VpQHRyZW5kbWljcm8uY29tLmNuPg0KDQpUaGlzIHBhdGNoIGZpeCB0aGUg
ZXJyb3IgaGFuZGxpbmcgaW4gbW94YXJ0X21hY19wcm9iZSgpOg0KIC0gcmV0dXJuIC1FTk9NRU0g
aW4gc29tZSBtZW1vcnkgYWxsb2MgZmFpbCBjYXNlcw0KIC0gYWRkIG1pc3NpbmcgZnJlZV9uZXRk
ZXYoKSBpbiB0aGUgZXJyb3IgaGFuZGxpbmcgY2FzZQ0KDQpTaWduZWQtb2ZmLWJ5OiBXZWkgWW9u
Z2p1biA8eW9uZ2p1bl93ZWlAdHJlbmRtaWNyby5jb20uY24+DQoNCg0KPHRhYmxlIGNsYXNzPSJU
TV9FTUFJTF9OT1RJQ0UiPjx0cj48dGQ+PHByZT4NClRSRU5EIE1JQ1JPIEVNQUlMIE5PVElDRQ0K
VGhlIGluZm9ybWF0aW9uIGNvbnRhaW5lZCBpbiB0aGlzIGVtYWlsIGFuZCBhbnkgYXR0YWNobWVu
dHMgaXMgY29uZmlkZW50aWFsIA0KYW5kIG1heSBiZSBzdWJqZWN0IHRvIGNvcHlyaWdodCBvciBv
dGhlciBpbnRlbGxlY3R1YWwgcHJvcGVydHkgcHJvdGVjdGlvbi4gDQpJZiB5b3UgYXJlIG5vdCB0
aGUgaW50ZW5kZWQgcmVjaXBpZW50LCB5b3UgYXJlIG5vdCBhdXRob3JpemVkIHRvIHVzZSBvciAN
CmRpc2Nsb3NlIHRoaXMgaW5mb3JtYXRpb24sIGFuZCB3ZSByZXF1ZXN0IHRoYXQgeW91IG5vdGlm
eSB1cyBieSByZXBseSBtYWlsIG9yDQp0ZWxlcGhvbmUgYW5kIGRlbGV0ZSB0aGUgb3JpZ2luYWwg
bWVzc2FnZSBmcm9tIHlvdXIgbWFpbCBzeXN0ZW0uDQo8L3ByZT48L3RkPjwvdHI+PC90YWJsZT4=
