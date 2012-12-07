From: Ani Sinha <ani@aristanetworks.com>
Subject: Re: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Thu, 6 Dec 2012 17:28:37 -0800 (PST)
Message-ID: <alpine.OSX.2.00.1212061723570.58531@animac.local>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com> <3246.1351717319@obiwan.sandelman.ca> <CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com> <87mwyi9h1x.fsf@xmission.com> <12918.1353190488@obiwan.sandelman.ca>
 <87obivu7n7.fsf@xmission.com> <CAOxq_8OC6zUm93mCHD5daxDmuYmmbUdgy0DnjfQdBKky_2t4nQ@mail.gmail.com> <87sj7iesdl.fsf@xmission.com> <CAOxq_8NbmOtvyH6Q=AVeOUAj7DoFO8cnVUQA5sgyEG7jEJXpHA@mail.gmail.com> <87hanyekr3.fsf@xmission.com>
Reply-To: ani@aristanetworks.com
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="0-1635437649-1354843719=:58531"
Cc: Michael Richardson <mcr@sandelman.ca>,
	tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49078 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755097Ab2LGB2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 20:28:42 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so4897595pbc.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 17:28:42 -0800 (PST)
In-Reply-To: <87hanyekr3.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--0-1635437649-1354843719=:58531
Content-Type: TEXT/PLAIN; charset=US-ASCII

>
> The patch is whitespace damaged.  And one of your test is using ||
> instead of &&
>

OK, using alpine now :-)
>
> The test should be && not ||.
>

aargh! I am retarded! Fixed. Hopefully 3rd time is a charm :-)


ani

--0-1635437649-1354843719=:58531
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=fix_vlan_tag_check.patch
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.OSX.2.00.1212061728370.58531@animac.local>
Content-Description: 
Content-Disposition: attachment; filename=fix_vlan_tag_check.patch

IHBjYXAtbGludXguYyB8ICAgNTAgKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0NCiAxIGZpbGVzIGNoYW5nZWQs
IDMxIGluc2VydGlvbnMoKyksIDE5IGRlbGV0aW9ucygtKQ0KDQpkaWZmIC0t
Z2l0IGEvcGNhcC1saW51eC5jIGIvcGNhcC1saW51eC5jDQppbmRleCBhNDJj
M2FjLi5iMmMxYTA4IDEwMDY0NA0KLS0tIGEvcGNhcC1saW51eC5jDQorKysg
Yi9wY2FwLWxpbnV4LmMNCkBAIC0xMzMsNiArMTMzLDcgQEAgc3RhdGljIGNv
bnN0IGNoYXIgcmNzaWRbXSBfVV8gPQ0KICNpbmNsdWRlIDxzeXMvdXRzbmFt
ZS5oPg0KICNpbmNsdWRlIDxzeXMvbW1hbi5oPg0KICNpbmNsdWRlIDxsaW51
eC9pZi5oPg0KKyNpbmNsdWRlIDxsaW51eC9pZl9wYWNrZXQuaD4NCiAjaW5j
bHVkZSA8bmV0aW5ldC9pbi5oPg0KICNpbmNsdWRlIDxsaW51eC9pZl9ldGhl
ci5oPg0KICNpbmNsdWRlIDxuZXQvaWZfYXJwLmg+DQpAQCAtMTU0Myw3ICsx
NTQ0LDEzIEBAIHBjYXBfcmVhZF9wYWNrZXQocGNhcF90ICpoYW5kbGUsIHBj
YXBfaGFuZGxlciBjYWxsYmFjaywgdV9jaGFyICp1c2VyZGF0YSkNCiAJCQkJ
Y29udGludWU7DQogDQogCQkJYXV4ID0gKHN0cnVjdCB0cGFja2V0X2F1eGRh
dGEgKilDTVNHX0RBVEEoY21zZyk7DQotCQkJaWYgKGF1eC0+dHBfdmxhbl90
Y2kgPT0gMCkNCisjaWYgZGVmaW5lZChUUF9TVEFUVVNfVkxBTl9WQUxJRCkN
CisgICAgICAgICAgICAgICAgICAgICAgICBpZiAoKGF1eC0+dHBfdmxhbl90
Y2kgPT0gMCkgJiYgIShhdXgtPnRwX3N0YXR1cyAmIFRQX1NUQVRVU19WTEFO
X1ZBTElEKSkNCisjZWxzZQ0KKwkJCWlmIChhdXgtPnRwX3ZsYW5fdGNpID09
IDApIC8qIHRoaXMgaXMgYW1iaWdpb3VzIGJ1dCB3aXRob3V0IHRoZQ0KKyAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIFRQX1NUQVRVU19WTEFOX1ZBTElEIGZsYWcsIHRoZXJlIGlzDQor
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgbm90aGluZyB0aGF0IHdlIGNhbiBkbyAqLw0KKyNlbmRpZg0K
IAkJCQljb250aW51ZTsNCiANCiAJCQlsZW4gPSBwYWNrZXRfbGVuID4gaW92
Lmlvdl9sZW4gPyBpb3YuaW92X2xlbiA6IHBhY2tldF9sZW47DQpAQCAtMzkz
Niw3ICszOTI2LDEyIEBAIHBjYXBfcmVhZF9saW51eF9tbWFwKHBjYXBfdCAq
aGFuZGxlLCBpbnQgbWF4X3BhY2tldHMsIHBjYXBfaGFuZGxlciBjYWxsYmFj
aywNCiAJCX0NCiANCiAjaWZkZWYgSEFWRV9UUEFDS0VUMg0KLQkJaWYgKGhh
bmRsZS0+bWQudHBfdmVyc2lvbiA9PSBUUEFDS0VUX1YyICYmIGguaDItPnRw
X3ZsYW5fdGNpICYmDQorICAgICAgICAgICAgICAgIGlmICgoaGFuZGxlLT5t
ZC50cF92ZXJzaW9uID09IFRQQUNLRVRfVjIpICYmDQorI2lmIGRlZmluZWQo
VFBfU1RBVFVTX1ZMQU5fVkFMSUQpDQorICAgICAgICAgICAgICAgICAgICAo
aC5oMi0+dHBfdmxhbl90Y2kgfHwgKGguaDItPnRwX3N0YXR1cyAmIFRQX1NU
QVRVU19WTEFOX1ZBTElEKSkgJiYNCisjZWxzZQ0KKyAgICAgICAgICAgICAg
ICAgICAgaC5oMi0+dHBfdmxhbl90Y2kgJiYNCisjZW5kaWYNCiAJCSAgICBo
YW5kbGUtPm1kLnZsYW5fb2Zmc2V0ICE9IC0xICYmDQogCQkgICAgdHBfc25h
cGxlbiA+PSAodW5zaWduZWQgaW50KSBoYW5kbGUtPm1kLnZsYW5fb2Zmc2V0
KSB7DQogCQkJc3RydWN0IHZsYW5fdGFnICp0YWc7DQoNCg==

--0-1635437649-1354843719=:58531--
