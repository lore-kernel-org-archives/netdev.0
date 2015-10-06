From: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>
Subject: Re: [PATCH net] ppp: don't override sk->sk_state in
 pppoe_flush_dev()
Date: Tue, 6 Oct 2015 04:46:04 +0000
Message-ID: <1444106764.1468.33.camel@mattb-dl>
References: <b7fbf103cd589741e3938550e7cf0f3684d8951c.1443605079.git.g.nault@alphalink.fr>
	 <7045c1dad4647944f61c958511d45fcd@visp.net.lb>
	 <20151002175426.GE2911@alphalink.fr>
	 <356ca8b8094bb2460c0182c00e120378@visp.net.lb>
	 <1444018131.14634.6.camel@mattb-dl> <20151005122459.GG2911@alphalink.fr>
	 <1444091180.1468.17.camel@mattb-dl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "core@irc.lg.ua" <core@irc.lg.ua>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paulus@samba.org" <paulus@samba.org>,
	"nuclearcat@nuclearcat.com" <nuclearcat@nuclearcat.com>
To: "g.nault@alphalink.fr" <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:38298 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJFEqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 00:46:11 -0400
In-Reply-To: <1444091180.1468.17.camel@mattb-dl>
Content-Language: en-US
Content-ID: <5397748E57C5A540BC71324B61A434BE@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFRoZSBzZWNvbmQgb25lIHNlZW1zIHRvIGJlIHRyaWNraWVyLiBJdCBsb29rcyBsaWtlIGEg
cmFjZSB3cnQuIFBBRFQNCj4gPiBtZXNzYWdlIHJlY2VwdGlvbi4gUmVwcm9kdWNpbmcgdGhlIGJ1
ZyB3aWxsIHByb2JhYmx5IHJlcXVpcmUgdG8NCj4gPiBnZW5lcmF0ZSBzb21lIFBBRFQgZmxvb2Rp
bmcgdG8gYSBob3N0IHRoYXQgY3JlYXRlcyBhbmQgcmVsZWFzZXMgUFBQb0UNCj4gPiBjb25uZWN0
aW9ucy4NCg0KT2sgSSB0aGluayBJIGNhbiBzZWUgdGhlIHBvdGVudGlhbCByYWNlIGhlcmUsIHNw
ZWNpZmljYWxseSB0aGUgUEFEVA0KZnJhbWUgaXMgcmVjZWl2ZWQgd2hpbGUgdGhlIHBwcG9lIGlu
dGVyZmFjZSBpcyBiZWluZyBkZWxldGVkLiAoSSB3aWxsDQpoYXZlIGEgZ28gaW5kdWNpbmcgdGhp
cyB3aXRoIG1zbGVlcCgpIGluIHRoZSBjb2RlIHRvbW9ycm93KQ0KDQoxLiBwcHBvZV9mbHVzaF9k
ZXYoKSAtIHNrLT5za19zdGF0ZSA9IFBQUE9YX0RFQUQsIHBvLT5wcHBvZV9kZXYgPSBOVUxMDQoN
CjIuIHBwcG9lX2Nvbm5lY3QoKSAtIHNrLT5za19zdGF0ZSA9IFBQUE9YX05PTkUsIHBvLT5wcHBv
ZV9kZXYgPSBOVUxMDQoNCjMuIHBwcG9lX2Rpc2NfcmN2KCkgLSBzay0+c2tfc3RhdGUgPSBQUFBP
WF9aT01CSUUgcG8tPnBwcG9lX2RldiA9IE5VTEwNCg0KNC4gcHBwb2VfcmVsZWFzZSgpIC0gZGV2
X3B1dChwby0+cHBwb2VfZGV2KSAtLS0tPiBPb3BzDQoNCg0KRWl0aGVyIGluIHBwcG9lX2Rpc2Nf
cmN2KCkgd2UgYWRkIHRoZSBjb25kaXRpb246DQoNCkBAIC00OTYsNyArNDk5LDggQEAgc3RhdGlj
IGludCBwcHBvZV9kaXNjX3JjdihzdHJ1Y3Qgc2tfYnVmZiAqc2tiLA0Kc3RydWN0IG5ldF9kZXZp
Y2UgKmRldiwNCiAgICAgICAgICAgICAgICAgICAgICAgIC8qIFdlJ3JlIG5vIGxvbmdlciBjb25u
ZWN0IGF0IHRoZSBQUFBPRSBsYXllciwNCiAgICAgICAgICAgICAgICAgICAgICAgICAqIGFuZCBt
dXN0IHdhaXQgZm9yIHBwcCBjaGFubmVsIHRvIGRpc2Nvbm5lY3QNCnVzLg0KICAgICAgICAgICAg
ICAgICAgICAgICAgICovDQotICAgICAgICAgICAgICAgICAgICAgICBzay0+c2tfc3RhdGUgPSBQ
UFBPWF9aT01CSUU7DQorICAgICAgICAgICAgICAgICAgICAgICBpZiAoc2stPnNrX3N0YXRlICYg
UFBQT1hfQ09OTkVDVEVEKQ0KKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzay0+c2tf
c3RhdGUgPSBQUFBPWF9aT01CSUU7DQogICAgICAgICAgICAgICAgfQ0KDQpPciBwZXJoYXBzIHdl
IHJlbW92ZSB0aGUgYXNzdW1wdGlvbiB0aGF0IHRoZSBzdGF0ZSBQUFBPWF9aT01CSUUgaGFzIGEN
Cm5vbi1udWxsIHBwcG9lX2RldiBvbiBpdC4NCg0KSSBkb24ndCBrbm93IHdoeSB0aGUgY29kZSBp
c24ndCBsaWtlIHRoZSBmb2xsb3dpbmcgYW55d2F5Lg0KDQotaWYgKHNrLT5za19zdGF0ZSAmIChQ
UFBPWF9DT05ORUNURUQgfCBQUFBPWF9CT1VORCB8IFBQUE9YX1pPTUJJRSkpIHsNCitpZiAocG8t
PnBwcG9lX2Rldikgew0KCWRldl9wdXQocG8tPnBwcG9lX2Rldik7DQoJcG8tPnBwcG9lX2RldiA9
IE5VTEw7DQp9DQo=
