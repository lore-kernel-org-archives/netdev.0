From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [RFC] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 07:47:53 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BC8F99@cnshjmbx02>
References: <20170614201748.28213-1-johannes@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
         <1497509862.2518.1.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8EFC@cnshjmbx02>
         <1497510716.2518.4.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8F15@cnshjmbx02>
 <1497512717.2518.5.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:54930 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750774AbdFOHr4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:47:56 -0400
In-Reply-To: <1497512717.2518.5.camel@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T2ssIHVuZGVyc3RhbmQgDQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTog
Sm9oYW5uZXMgQmVyZyBbbWFpbHRvOmpvaGFubmVzQHNpcHNvbHV0aW9ucy5uZXRdDQo+IFNlbnQ6
IFRodXJzZGF5LCBKdW5lIDE1LCAyMDE3IDM6NDUgUE0NCj4gVG86IFlVQU4gTGlueXU7IG5ldGRl
dkB2Z2VyLmtlcm5lbC5vcmcNCj4gU3ViamVjdDogUmU6IFtSRkNdIG5ldHdvcmtpbmc6IGNvbnZl
cnQgbWFueSBtb3JlIHBsYWNlcyB0byBza2JfcHV0X3plcm8oKQ0KPiANCj4gT24gVGh1LCAyMDE3
LTA2LTE1IGF0IDA3OjIwICswMDAwLCBZVUFOIExpbnl1IHdyb3RlOg0KPiA+ID4NCj4gPiBJbiBt
eSBvcGluaW9uIGlmIHNwYXRjaCBjYW4gZG8gaXQgZXZlbiBpdCBmb3VuZCBvbmUgcGxhY2UsIGtl
ZXAgaXQuDQo+ID4gT25seSBsZWF2ZSBkaWZmaWN1bHQgcGxhY2VzIGxpa2UgbmRpc2MuYyB0byBt
ZS4NCj4gDQo+IEl0J3Mgbm90IHNvIHNpbXBsZSAtIEknZCBoYXZlIHRvIHRhaWxvciB0aGUgc3Bh
dGNoIHRvIGl0IHByZXR0eSBtdWNoIEkNCj4gZ3Vlc3MsIHNwZW5kaW5nIGZhciBtb3JlIHRpbWUg
b24gdGhlIHNwYXRjaCB0aGFuIHRoZSBzaW5nbGUgcGxhY2UNCj4gd2FycmFudHMuDQo+IA0KPiA+
ID4gQnR3LCBqdXN0IG1hZGUgYSBwYXRjaCB0byBhZGQgYW5kIHVzZSAic2tiX3B1dF9kYXRhKCki
LCBqdXN0IGRvaW5nDQo+ID4gPiBhDQo+ID4gPiBtZW1jcHkoKSBpbnRvIHRoZSBza2JfcHV0KCkg
YXJlYSBhbHNvIGhhcyBsb3RzIG9mIHVzZXJzLg0KPiA+DQo+ID4gWWVzLCBJIGFsc28gbm90aWNl
IHNvbWUgcGxhY2VzLg0KPiANCj4gSSBzZW50IGEgcGF0Y2guDQo+IA0KPiBqb2hhbm5lcw0K
