From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH] wireless: adf702x: new driver for
	ADF7020/21 parts
Date: Tue, 19 Jan 2010 02:37:24 -0500
Message-ID: <8bd0f97a1001182337w5b8bf071v1ec90a8a2f5949e5@mail.gmail.com>
References: <1261447929-17106-1-git-send-email-vapier@gentoo.org>
	<1261453449.25157.367.camel@localhost> <8A42379416420646B9BFAC9682273B6D0EF11F8A@limkexm3.ad.analog.com>
	<1261497729.2845.8.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Cc: "Hennerich, Michael" <Michael.Hennerich@analog.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	uclinux-dist-devel@blackfin.uclinux.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:63967 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487Ab0ASHho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 02:37:44 -0500
Received: by yxe17 with SMTP id 17so4619963yxe.33
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 23:37:44 -0800 (PST)
In-Reply-To: <1261497729.2845.8.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVHVlLCBEZWMgMjIsIDIwMDkgYXQgMTE6MDIsIEJlbiBIdXRjaGluZ3Mgd3JvdGU6Cj4gT24g
VHVlLCAyMDA5LTEyLTIyIGF0IDExOjQ2ICswMDAwLCBIZW5uZXJpY2gsIE1pY2hhZWwgd3JvdGU6
Cj4+ID4+ICtzdGF0aWMgaXJxcmV0dXJuX3QgYWRmNzAyeF9yeF9pbnRlcnJ1cHQoaW50IGlycSwg
dm9pZCAqZGV2X2lkKQo+PiA+PiArewo+PiA+Wy4uLl0KPj4gPj4gKyDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoGxwLT5yeF9zaXplID0gYWRmNzAyeF9nZXRyeHNpemUobHAsIG9mZnNldCk7Cj4+
ID4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBpZiAob2Zmc2V0ID09IDEpIHsKPj4gPj4g
KyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHNldF9kbWFfeF9jb3VudChs
cC0+ZG1hX2NoX3J4LCBscC0+cnhfc2l6ZSk7Cj4+ID4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqBzZXRfZG1hX3N0YXJ0X2FkZHIobHAtPmRtYV9jaF9yeCwKPj4gPj4g
KyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCh1bnNp
Z25lZCBsb25nKWxwLT5yeF9idWYpOwo+PiA+PiArIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
fSBlbHNlIHsKPj4gPj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoGxw
LT5yeF9idWZbMF0gPSBscC0+cnhfYnVmWzNdOwo+PiA+PiArIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgc2V0X2RtYV94X2NvdW50KGxwLT5kbWFfY2hfcngsIGxwLT5yeF9z
aXplIC0gMSk7Cj4+ID4+ICsgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBz
ZXRfZG1hX3N0YXJ0X2FkZHIobHAtPmRtYV9jaF9yeCwKPj4gPj4gKyDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCh1bnNpZ25lZCBsb25nKSZscC0+cnhf
YnVmWzFdKTsKPj4gPj4gKyDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoH0KPj4gPj4gKyDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoGVuYWJsZV9kbWEobHAtPmRtYV9jaF9yeCk7Cj4+ID4+ICsg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBTU1lOQygpOwo+PiA+Cj4+ID5JcyB0aGlzIHNvbWUg
b2RkIGtpbmQgb2YgbWVtb3J5IGJhcnJpZXI/Cj4+Cj4+IFdlbGwgLSBpdCdzIGFuIGluc3RydWN0
aW9uIHRoYXQgZW5zdXJlcyB0aGF0IHRoZSB3cml0ZSBidWZmZXJzIGFyZSBmbHVzaGVkIGFuZCBh
bGwgaW5zdHJ1Y3Rpb25zIGV4ZWN1dGVkLgo+Cj4gSSBzdXNwZWN0IHlvdSBvbmx5IG5lZWQgYSB3
cml0ZSBtZW1vcnkgYmFycmllciBoZXJlICh3bWIoKSkgbm90IGEKPiBwaXBlbGluZSBmbHVzaC4K
Cml0J3Mgbm90IGEgcGlwZWxpbmUgZmx1c2gsIGl0J3MgYW5vdGhlciBCbGFja2ZpbiBmdW4gcGll
Y2UgLS0gaXQgZG9lcwphIHN5c3RlbSBzeW5jIHdpdGggdGhlIERNQSByZWdpc3RlcnMKLW1pa2UK
