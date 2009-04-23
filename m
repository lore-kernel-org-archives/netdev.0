From: Ken Lewis <kennylewis@gmail.com>
Subject: Re: April 22 Next : net/rfkill randconfig failure
Date: Thu, 23 Apr 2009 11:33:13 +0100
Message-ID: <5a44caba0904230333v88a2a81j3f86cfb46b3ec33c@mail.gmail.com>
References: <20090422154247.dbffd285.sfr@canb.auug.org.au>
	 <49EEF38D.8000801@in.ibm.com>
	 <a4423d670904230254v672798ddtda443e549ef45490@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016364ee12a3d7e8f046836680d
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexander Beregalov <a.beregalov@gmail.com>,
	Sachin Sant <sachinp@in.ibm.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f118.google.com ([209.85.221.118]:36724 "EHLO
	mail-qy0-f118.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbZDWKdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 06:33:14 -0400
In-Reply-To: <a4423d670904230254v672798ddtda443e549ef45490@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016364ee12a3d7e8f046836680d
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

2009/4/23 Alexander Beregalov <a.beregalov@gmail.com>:
> 2009/4/22 Sachin Sant <sachinp@in.ibm.com>:
>> Today's next tree build (x86 randconfig) failed with
>>
>> net/rfkill/rfkill.c: In function 'update_rfkill_state':
>> net/rfkill/rfkill.c:99: error: implicit declaration of function
>> 'rfkill_led_trigger'
>> make[2]: *** [net/rfkill/rfkill.o] Error 1
>>
>> .config attached
>>
>
> Add CCs

I'm getting the same issue, but my .config does not include
CONFIG_RFKILL_LEDS.  I use the attached patch to ensure the functions
were defined.  Apols for the formatting: first patch atttempt.

Take care.
Ken.

--0016364ee12a3d7e8f046836680d
Content-Type: text/plain; charset=US-ASCII; name="next-20090423-rfkill-diff.txt"
Content-Disposition: attachment; filename="next-20090423-rfkill-diff.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ftvbe0q70

ZGlmZiAtLWdpdCBhL25ldC9yZmtpbGwvcmZraWxsLmMgYi9uZXQvcmZraWxsL3Jma2lsbC5jCmlu
ZGV4IDUzNDMwYTcuLmZjZGQ1ZTAgMTAwNjQ0Ci0tLSBhL25ldC9yZmtpbGwvcmZraWxsLmMKKysr
IGIvbmV0L3Jma2lsbC9yZmtpbGwuYwpAQCAtNzUsNiArNzUsMTIgQEAgc3RhdGljIHZvaWQgcmZr
aWxsX2xlZF90cmlnZ2VyX2FjdGl2YXRlKHN0cnVjdCBsZWRfY2xhc3NkZXYgKmxlZCkKIAogCXJm
a2lsbF9sZWRfdHJpZ2dlcihyZmtpbGwsIHJma2lsbC0+c3RhdGUpOwogfQorI2Vsc2UKK3N0YXRp
YyB2b2lkIHJma2lsbF9sZWRfdHJpZ2dlcihzdHJ1Y3QgcmZraWxsICpyZmtpbGwsCisJCQkgICAg
ICAgZW51bSByZmtpbGxfc3RhdGUgc3RhdGUpCit7IH0KK3N0YXRpYyB2b2lkIHJma2lsbF9sZWRf
dHJpZ2dlcl9hY3RpdmF0ZShzdHJ1Y3QgbGVkX2NsYXNzZGV2ICpsZWQpCit7IH0KICNlbmRpZiAv
KiBDT05GSUdfUkZLSUxMX0xFRFMgKi8KIAogc3RhdGljIHZvaWQgcmZraWxsX3VldmVudChzdHJ1
Y3QgcmZraWxsICpyZmtpbGwpCg==
--0016364ee12a3d7e8f046836680d--
