From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [RFC] networking: convert many more places to skb_put_zero()
Date: Thu, 15 Jun 2017 07:20:37 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BC8F15@cnshjmbx02>
References: <20170614201748.28213-1-johannes@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8D22@cnshjmbx02>
         <1497509862.2518.1.camel@sipsolutions.net>
         <8729016553E3654398EA69218DA29EEF15BC8EFC@cnshjmbx02>
 <1497510716.2518.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Johannes Berg <johannes@sipsolutions.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:64882 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750774AbdFOHUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 03:20:40 -0400
In-Reply-To: <1497510716.2518.4.camel@sipsolutions.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCj4gLS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gRnJvbTogSm9oYW5uZXMgQmVyZyBb
bWFpbHRvOmpvaGFubmVzQHNpcHNvbHV0aW9ucy5uZXRdDQo+IFNlbnQ6IFRodXJzZGF5LCBKdW5l
IDE1LCAyMDE3IDM6MTIgUE0NCj4gVG86IFlVQU4gTGlueXU7IG5ldGRldkB2Z2VyLmtlcm5lbC5v
cmcNCj4gU3ViamVjdDogUmU6IFtSRkNdIG5ldHdvcmtpbmc6IGNvbnZlcnQgbWFueSBtb3JlIHBs
YWNlcyB0byBza2JfcHV0X3plcm8oKQ0KPiANCj4gT24gVGh1LCAyMDE3LTA2LTE1IGF0IDA3OjA1
ICswMDAwLCBZVUFOIExpbnl1IHdyb3RlOg0KPiA+ID4gQEANCj4gPiA+IHR5cGUgdDsNCj4gPiA+
IGV4cHJlc3Npb24gc2tiLCBsZW47DQo+ID4gPiBpZGVudGlmaWVyIHA7DQo+ID4gPiBAQA0KPiA+
ID4gdCAqcA0KPiA+ID4gLSA9IHNrYl9wdXQoc2tiLCBsZW4pOw0KPiA+ID4gKyA9IHNrYl9wdXRf
emVybyhza2IsIGxlbik7DQo+ID4gPiAtbWVtc2V0KHAsIDAsIGxlbik7DQo+ID4gPg0KPiA+ID4g
YW5kIGl0IGNhbid0IGZpZ3VyZSBvdXQgdGhhdCBpdCBzaG91bGQgcmVtb3ZlIHRoZSB2YXJpYWJs
ZSwgd2l0aG91dA0KPiA+ID4gbXVjaCBtb3JlIHdvcmsgdGhhdCdzIG5vdCByZWFsbHkgd29ydGgg
aXQgZm9yIG9uZSBpbnN0YW5jZSA6KQ0KPiA+DQo+ID4gWWVzLCBJIGFncmVlLA0KPiA+IGl0IGNv
bmZsaWN0IHdpdGggcHJldmlvdXMgc3BhdGNoIHdoaWNoIHdpbGwga2VlcCAicGFkIiB2YXJpYWJs
ZSwNCj4gPiByaWdodD8NCj4gPg0KPiA+IEkgY2FuIGRvIGl0IGJ5IGhhbmQgaWYgc3BhdGNoIG5v
dCB3b3JrDQo+IA0KPiBJIGNvdWxkIHRlYWNoIHNwYXRjaCwgYnV0IGl0J3MgdXN1YWxseSBmYXN0
ZXIgKGZvciBtZSkgdG8gcG9zdC1wcm9jZXNzDQo+IHRoZSBzcGF0Y2ggY2hhbmdlcyB0byByZW1v
dmUgdGhlIGV4dHJhIHZhcmlhYmxlIC0gaW4gdGhpcyBjYXNlIHRob3VnaCwNCj4gaXQncyBqdXN0
IG5vdCB3b3J0aCBpdCBhdCBhbGwgc2luY2UgdGhlcmUncyBqdXN0IGEgc2luZ2xlIGNoYW5nZSBh
bmQNCj4geW91IGFscmVhZHkgaGF2ZSBhIHNlcGFyYXRlIHBhdGNoIDopDQpJbiBteSBvcGluaW9u
IGlmIHNwYXRjaCBjYW4gZG8gaXQgZXZlbiBpdCBmb3VuZCBvbmUgcGxhY2UsIGtlZXAgaXQuDQpP
bmx5IGxlYXZlIGRpZmZpY3VsdCBwbGFjZXMgbGlrZSBuZGlzYy5jIHRvIG1lLg0KPiANCj4gQnR3
LCBqdXN0IG1hZGUgYSBwYXRjaCB0byBhZGQgYW5kIHVzZSAic2tiX3B1dF9kYXRhKCkiLCBqdXN0
IGRvaW5nIGENCj4gbWVtY3B5KCkgaW50byB0aGUgc2tiX3B1dCgpIGFyZWEgYWxzbyBoYXMgbG90
cyBvZiB1c2Vycy4NClllcywgSSBhbHNvIG5vdGljZSBzb21lIHBsYWNlcy4NCj4gDQo+IGpvaGFu
bmVzDQo=
