From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 19:02:34 -0700
Message-ID: <86802c440808201902t26fa858em76824478eeb818b3@mail.gmail.com>
References: <324173.33114.qm@web82106.mail.mud.yahoo.com>
	 <86802c440808201058s5141c10fnf2b843525f8c545@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_16406_21007556.1219284154752"
Cc: "Ingo Molnar" <mingo@elte.hu>, "Vivek Goyal" <vgoyal@redhat.com>,
	"Bill Fink" <billfink@mindspring.com>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Peter Zijlstra" <peterz@infradead.org>,
	"Thomas Gleixner" <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: "David Witbrodt" <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:5580 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673AbYHUCCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 22:02:35 -0400
Received: by rv-out-0506.google.com with SMTP id k40so731686rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 19:02:35 -0700 (PDT)
In-Reply-To: <86802c440808201058s5141c10fnf2b843525f8c545@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_16406_21007556.1219284154752
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

please apply attached patch to see if insert_resource/request resource
works on your conf

YH

------=_Part_16406_21007556.1219284154752
Content-Type: text/x-patch; name=insert_resource_debug.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fk4q91130
Content-Disposition: attachment; filename=insert_resource_debug.patch

SW5kZXg6IGxpbnV4LTIuNi9rZXJuZWwvcmVzb3VyY2UuYwo9PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0y
LjYub3JpZy9rZXJuZWwvcmVzb3VyY2UuYworKysgbGludXgtMi42L2tlcm5lbC9yZXNvdXJjZS5j
CkBAIC0yMDEsNiArMjAxLDcgQEAgaW50IHJlcXVlc3RfcmVzb3VyY2Uoc3RydWN0IHJlc291cmNl
ICpybwogCXdyaXRlX2xvY2soJnJlc291cmNlX2xvY2spOwogCWNvbmZsaWN0ID0gX19yZXF1ZXN0
X3Jlc291cmNlKHJvb3QsIG5ldyk7CiAJd3JpdGVfdW5sb2NrKCZyZXNvdXJjZV9sb2NrKTsKKwlw
cmludGsoS0VSTl9ERUJVRyAicmVxdWVzdF9yZXNvdXJjZTogcm9vdDogKCVzKSBbJWxseCwgJWxs
eF0sIG5ldzogKCVzKSBbJWxseCwgJWxseF0gY29uZmxpY3QgJWRcbiIsIHJvb3QtPm5hbWUsIHJv
b3QtPnN0YXJ0LCByb290LT5lbmQsIG5ldy0+bmFtZSwgbmV3LT5zdGFydCwgbmV3LT5lbmQsICEh
Y29uZmxpY3QpOwogCXJldHVybiBjb25mbGljdCA/IC1FQlVTWSA6IDA7CiB9CiAKQEAgLTM4Miwx
NiArMzgzLDIwIEBAIGludCBpbnNlcnRfcmVzb3VyY2Uoc3RydWN0IHJlc291cmNlICpwYXIKIAog
CXdyaXRlX2xvY2soJnJlc291cmNlX2xvY2spOwogCisJcHJpbnRrKEtFUk5fREVCVUcgImluc2Vy
dF9yZXNvdXJjZTogcGFyZW50OiAoJXMpIFslbGx4LCAlbGx4XSwgbmV3OiAoJXMpIFslbGx4LCAl
bGx4XVxuIiwgcGFyZW50LT5uYW1lLCBwYXJlbnQtPnN0YXJ0LCBwYXJlbnQtPmVuZCwgbmV3LT5u
YW1lLCBuZXctPnN0YXJ0LCBuZXctPmVuZCk7CiAJZm9yICg7OyBwYXJlbnQgPSBmaXJzdCkgewog
CSAJcmVzdWx0ID0gMDsKIAkJZmlyc3QgPSBfX3JlcXVlc3RfcmVzb3VyY2UocGFyZW50LCBuZXcp
OwotCQlpZiAoIWZpcnN0KQorCQlpZiAoIWZpcnN0KSB7CisJCQlwcmludGsoS0VSTl9ERUJVRyAi
ICAgIGluc2VydF9yZXNvdXJjZTogZ29vZCB3aXRoIHJlcXVlc3QgZGlyZWN0IHBhcmVudDogKCVz
KSBbJWxseCwgJWxseF0sIG5ldzogKCVzKSBbJWxseCwgJWxseF1cbiIsIHBhcmVudC0+bmFtZSwg
cGFyZW50LT5zdGFydCwgcGFyZW50LT5lbmQsIG5ldy0+bmFtZSwgbmV3LT5zdGFydCwgbmV3LT5l
bmQpOwogCQkJZ290byBvdXQ7CisJCX0KIAogCQlyZXN1bHQgPSAtRUJVU1k7CiAJCWlmIChmaXJz
dCA9PSBwYXJlbnQpCiAJCQlnb3RvIG91dDsKIAorCQlwcmludGsoS0VSTl9ERUJVRyAiICBpbnNl
cnRfcmVzb3VyY2U6IGZpcnN0OiAoJXMpIFslbGx4LCAlbGx4XSwgbmV3OiAoJXMpIFslbGx4LCAl
bGx4XVxuIiwgZmlyc3QtPm5hbWUsIGZpcnN0LT5zdGFydCwgZmlyc3QtPmVuZCwgbmV3LT5uYW1l
LCBuZXctPnN0YXJ0LCBuZXctPmVuZCk7CiAJCWlmICgoZmlyc3QtPnN0YXJ0ID4gbmV3LT5zdGFy
dCkgfHwgKGZpcnN0LT5lbmQgPCBuZXctPmVuZCkpCiAJCQlicmVhazsKIAkJaWYgKChmaXJzdC0+
c3RhcnQgPT0gbmV3LT5zdGFydCkgJiYgKGZpcnN0LT5lbmQgPT0gbmV3LT5lbmQpKQpAQCAtNDEz
LDEwICs0MTgsMTMgQEAgaW50IGluc2VydF9yZXNvdXJjZShzdHJ1Y3QgcmVzb3VyY2UgKnBhcgog
CW5ldy0+cGFyZW50ID0gcGFyZW50OwogCW5ldy0+c2libGluZyA9IG5leHQtPnNpYmxpbmc7CiAJ
bmV3LT5jaGlsZCA9IGZpcnN0OworCXByaW50ayhLRVJOX0RFQlVHICIgIGluc2VydF9yZXNvdXJj
ZTogZGlyZWN0IHBhcmVudDogKCVzKSBbJWxseCwgJWxseF0sIG5ldzogKCVzKSBbJWxseCwgJWxs
eF1cbiIsIHBhcmVudC0+bmFtZSwgcGFyZW50LT5zdGFydCwgcGFyZW50LT5lbmQsIG5ldy0+bmFt
ZSwgbmV3LT5zdGFydCwgbmV3LT5lbmQpOwogCiAJbmV4dC0+c2libGluZyA9IE5VTEw7Ci0JZm9y
IChuZXh0ID0gZmlyc3Q7IG5leHQ7IG5leHQgPSBuZXh0LT5zaWJsaW5nKQorCWZvciAobmV4dCA9
IGZpcnN0OyBuZXh0OyBuZXh0ID0gbmV4dC0+c2libGluZykgewogCQluZXh0LT5wYXJlbnQgPSBu
ZXc7CisJCXByaW50ayhLRVJOX0RFQlVHICIgICAgaW5zZXJ0X3Jlc291cmNlOiBjaGlsZDogKCVz
KSBbJWxseCwgJWxseF0sIG5ldzogKCVzKSBbJWxseCwgJWxseF1cbiIsIG5leHQtPm5hbWUsIG5l
eHQtPnN0YXJ0LCBuZXh0LT5lbmQsIG5ldy0+bmFtZSwgbmV3LT5zdGFydCwgbmV3LT5lbmQpOwor
CX0KIAogCWlmIChwYXJlbnQtPmNoaWxkID09IGZpcnN0KSB7CiAJCXBhcmVudC0+Y2hpbGQgPSBu
ZXc7Cg==
------=_Part_16406_21007556.1219284154752--
