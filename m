From: Patrick Ruddy <pruddy@Brocade.com>
Subject: Re: [PATCH] Netlink messages for multicast HW addr programming
Date: Fri, 22 Jan 2016 14:51:55 +0000
Message-ID: <1453474315.20378.7.camel@brocade.com>
References: <1453376874-17389-1-git-send-email-pruddy@brocade.com>
	 <20160121200419.GB2251@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Stapleton <dstaplet@Brocade.com>,
	Olufemi Komolafe <okomolaf@Brocade.com>,
	"Stephen Hemminger" <shemming@Brocade.com>
To: "jiri@resnulli.us" <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:52590 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753640AbcAVOwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 09:52:02 -0500
Received: from pps.filterd (m0048193.ppops.net [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u0ME52ZF028945
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 06:52:01 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
	by mx0a-000f0801.pphosted.com with ESMTP id 20gmypdfrq-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 Jan 2016 06:52:01 -0800
In-Reply-To: <20160121200419.GB2251@nanopsycho.orion>
Content-Language: en-US
Content-ID: <C0FB026F800FED4BAC31D98D80E7BA21@brocade.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gVGh1LCAyMDE2LTAxLTIxIGF0IDIxOjA0ICswMTAwLCBKaXJpIFBpcmtvIHdyb3RlOg0KPiBU
aHUsIEphbiAyMSwgMjAxNiBhdCAxMjo0Nzo1NFBNIENFVCwgcHJ1ZGR5QGJyb2NhZGUuY29tIHdy
b3RlOg0KPiA+QWRkIFJUTV9ORVdBRERSIGFuZCBSVE1fREVMQUREUiBuZXRsaW5rIG1lc3NhZ2Vz
IHRvIGluZGljYXRlDQo+ID5pbnRlcmVzdCBpbiBzcGVjaWZpYyBtdWx0aWNhc3QgaGFyZHdhcmUg
YWRkcmVzc2VzLiBUaGVzZSBtZXNzYWdlcw0KPiA+YXJlIHNlbnQgd2hlbiBhZGRyZXNzZWQgYXJl
IGFkZGVkIG9yIGRlbGV0ZWQgZnJvbSB0aGUgYXBwcm9wcmlhdGUNCj4gPmludGVyZmFjZSBkcml2
ZXIuDQo+ID4NCj4gPlNpZ25lZC1vZmYtYnk6IFBhdHJpY2sgUnVkZHkgPHBydWRkeUBicm9jYWRl
LmNvbT4NCj4gPg0KPiA+ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Rldl9hZGRyX2xpc3RzLmMgYi9u
ZXQvY29yZS9kZXZfYWRkcl9saXN0cy5jDQo+ID5pbmRleCBjMDU0OGQyLi5hMGViYWRkIDEwMDY0
NA0KPiA+LS0tIGEvbmV0L2NvcmUvZGV2X2FkZHJfbGlzdHMuYw0KPiA+KysrIGIvbmV0L2NvcmUv
ZGV2X2FkZHJfbGlzdHMuYw0KPiA+QEAgLTEyLDYgKzEyLDcgQEANCj4gPiAgKi8NCj4gPiANCj4g
PiAjaW5jbHVkZSA8bGludXgvbmV0ZGV2aWNlLmg+DQo+ID4rI2luY2x1ZGUgPG5ldC9uZXRsaW5r
Lmg+DQo+ID4gI2luY2x1ZGUgPGxpbnV4L3J0bmV0bGluay5oPg0KPiA+ICNpbmNsdWRlIDxsaW51
eC9leHBvcnQuaD4NCj4gPiAjaW5jbHVkZSA8bGludXgvbGlzdC5oPg0KPiA+QEAgLTY2MSw2ICs2
NjIsNjIgQEAgb3V0Og0KPiA+IH0NCj4gPiBFWFBPUlRfU1lNQk9MKGRldl9tY19hZGRfZXhjbCk7
DQo+ID4gDQo+ID4rc3RhdGljIGludCBmaWxsX2FkZHIoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3Ry
dWN0IG5ldF9kZXZpY2UgKmRldiwNCj4gPisJCSAgICAgY29uc3QgdW5zaWduZWQgY2hhciAqYWRk
ciwgaW50IHR5cGUpDQo+ID4rew0KPiA+KwlzdHJ1Y3Qgbmxtc2doZHIgKm5saDsNCj4gPisJc3Ry
dWN0IGlmYWRkcm1zZyAqaWZtOw0KPiA+Kw0KPiA+KwlubGggPSBubG1zZ19wdXQoc2tiLCAwLCAw
LCB0eXBlLCBzaXplb2YoKmlmbSksIDApOw0KPiA+KwlpZiAobmxoID09IE5VTEwpDQo+ID4rCQly
ZXR1cm4gLUVNU0dTSVpFOw0KPiA+Kw0KPiA+KwlpZm0gPSBubG1zZ19kYXRhKG5saCk7DQo+ID4r
CWlmbS0+aWZhX2ZhbWlseSA9IEFGX1VOU1BFQzsNCj4gPisJaWZtLT5pZmFfcHJlZml4bGVuID0g
MDsNCj4gPisJaWZtLT5pZmFfZmxhZ3MgPSBJRkFfRl9QRVJNQU5FTlQ7DQo+ID4rCWlmbS0+aWZh
X3Njb3BlID0gUlRfU0NPUEVfTElOSzsNCj4gPisJaWZtLT5pZmFfaW5kZXggPSBkZXYtPmlmaW5k
ZXg7DQo+ID4rCWlmIChubGFfcHV0KHNrYiwgSUZBX0FERFJFU1MsIGRldi0+YWRkcl9sZW4sIGFk
ZHIpKQ0KPiA+KwkJZ290byBubGFfcHV0X2ZhaWx1cmU7DQo+ID4rCW5sbXNnX2VuZChza2IsIG5s
aCk7DQo+IA0KPiBIb3cgY2FuIHVzZXJzcGFjZSB0ZWxsIGlmIHRoaXMgaXMgYSBtdWx0aWNhc3Qg
YWRkcj8gQWxzbywgd2h5IG5vdCBhZGQNCj4gbm90aWZpY2F0aW9ucyBmb3IgdW5pY2FzdCBhZGRy
cyBzbyB3ZSBoYW5kbGUgYm90aCB0aGUgc2FtZT8NCg0KSSBhbSBvbmx5IHVzaW5nIHRoaXMgUlRN
X05FVy9ERUxBRERSIEFGX1VOU1BFQyBtZXNzYWdlIGZvciBtdWx0aWNhc3QNCmFkZHJlc3Nlcy4g
SSB1bmRlcnN0YW5kIHRoYXQgdGhlIHVuaWNhc3QgYWRkcmVzc2VzIGFyZSBub3RpZmllZCBpbiB0
aGUNClJUTV9ORVcvREVMTElOSy4NCg0KLXByDQo=
