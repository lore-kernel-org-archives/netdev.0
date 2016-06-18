From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [BUG] act_ife: sleeping functions called in atomic context
Date: Sat, 18 Jun 2016 10:38:58 -0400
Message-ID: <57655D02.6090402@mojatatu.com>
References: <1466110219-4825-1-git-send-email-khoroshilov@ispras.ru>
 <CAM_iQpWyfmUnQkQPz8dfO1NPmbdmW3AB9yWrJk6TqXyTo_DCow@mail.gmail.com>
 <57634687.3050107@mojatatu.com>
 <CAM_iQpVkFvgbYQsVB0hFKa5zVa1KCPAz=cQ7sAXdJwNM=8hpzQ@mail.gmail.com>
 <CAM_iQpXokKbXS8TiOgYqEZgLMY-01X8ebJQ-b6VrnM2x6=GFhg@mail.gmail.com>
 <5763D9F6.6020305@mojatatu.com>
 <CAM_iQpXZA=98EKc9fTnq9W3XzuPG3zMpg22dzCpuOWVup2P=Qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090309060501080801060007"
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, ldv-project@linuxtesting.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:37007 "EHLO
	mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbcFROjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 10:39:02 -0400
Received: by mail-it0-f41.google.com with SMTP id f6so8538894ith.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 07:39:00 -0700 (PDT)
In-Reply-To: <CAM_iQpXZA=98EKc9fTnq9W3XzuPG3zMpg22dzCpuOWVup2P=Qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090309060501080801060007
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

On 16-06-17 01:31 PM, Cong Wang wrote:

> My patch is against -net. (I see you already figured out your patch is
> missing in -net-next.)
>

Ok, should have re-read this email before working on the patch;->

> Or are you suggesting to rebase it for -net-next? I think it fixes some real
> bug so -net is better, although it is slightly large as a bug fix.
>

I am conflicted. There are a lot of changes in net-next at the moment;
adding this to -net seems like will definetely cause merge issues for
Dave.

Ok, Cong - patch attached and tested. Let me know what you think.

cheers,
jamal



--------------090309060501080801060007
Content-Type: text/plain; charset=UTF-8;
 name="patchlet1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="patchlet1"

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9hY3RfaWZlLmMgYi9uZXQvc2NoZWQvYWN0X2lmZS5j
CmluZGV4IGI3ZmE5NjkuLmI1MmRlYjQgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9hY3RfaWZl
LmMKKysrIGIvbmV0L3NjaGVkL2FjdF9pZmUuYwpAQCAtMjM5LDggKzIzOSw3IEBAIHN0YXRp
YyBpbnQgaWZlX3ZhbGlkYXRlX21ldGF0eXBlKHN0cnVjdCB0Y2ZfbWV0YV9vcHMgKm9wcywg
dm9pZCAqdmFsLCBpbnQgbGVuKQogCXJldHVybiByZXQ7CiB9CiAKLS8qIGNhbGxlZCB3aGVu
IGFkZGluZyBuZXcgbWV0YSBpbmZvcm1hdGlvbgotICogdW5kZXIgaWZlLT50Y2ZfbG9jawor
LyogY2FsbGVkIHRvIGZpbmQgbmV3IG1ldGFkYXRhIG9wcy4gUG9zc2libHkgbG9hZCBpdCBh
cyBhIG1vZHVsZS4KICovCiBzdGF0aWMgaW50IGxvYWRfbWV0YW9wc19hbmRfdmV0KHN0cnVj
dCB0Y2ZfaWZlX2luZm8gKmlmZSwgdTMyIG1ldGFpZCwKIAkJCQl2b2lkICp2YWwsIGludCBs
ZW4pCkBAIC0yNTEsMTEgKzI1MCw5IEBAIHN0YXRpYyBpbnQgbG9hZF9tZXRhb3BzX2FuZF92
ZXQoc3RydWN0IHRjZl9pZmVfaW5mbyAqaWZlLCB1MzIgbWV0YWlkLAogCWlmICghb3BzKSB7
CiAJCXJldCA9IC1FTk9FTlQ7CiAjaWZkZWYgQ09ORklHX01PRFVMRVMKLQkJc3Bpbl91bmxv
Y2tfYmgoJmlmZS0+dGNmX2xvY2spOwogCQlydG5sX3VubG9jaygpOwogCQlyZXF1ZXN0X21v
ZHVsZSgiaWZlbWV0YSV1IiwgbWV0YWlkKTsKIAkJcnRubF9sb2NrKCk7Ci0JCXNwaW5fbG9j
a19iaCgmaWZlLT50Y2ZfbG9jayk7CiAJCW9wcyA9IGZpbmRfaWZlX29wbGlzdChtZXRhaWQp
OwogI2VuZGlmCiAJfQpAQCAtMjcyLDcgKzI2OSw2IEBAIHN0YXRpYyBpbnQgbG9hZF9tZXRh
b3BzX2FuZF92ZXQoc3RydWN0IHRjZl9pZmVfaW5mbyAqaWZlLCB1MzIgbWV0YWlkLAogfQog
CiAvKiBjYWxsZWQgd2hlbiBhZGRpbmcgbmV3IG1ldGEgaW5mb3JtYXRpb24KLSAqIHVuZGVy
IGlmZS0+dGNmX2xvY2sKICovCiBzdGF0aWMgaW50IGFkZF9tZXRhaW5mbyhzdHJ1Y3QgdGNm
X2lmZV9pbmZvICppZmUsIHUzMiBtZXRhaWQsIHZvaWQgKm1ldGF2YWwsCiAJCQlpbnQgbGVu
KQpAQCAtMzAyLDcgKzI5OCw5IEBAIHN0YXRpYyBpbnQgYWRkX21ldGFpbmZvKHN0cnVjdCB0
Y2ZfaWZlX2luZm8gKmlmZSwgdTMyIG1ldGFpZCwgdm9pZCAqbWV0YXZhbCwKIAkJfQogCX0K
IAorCXNwaW5fbG9ja19iaCgmaWZlLT50Y2ZfbG9jayk7CiAJbGlzdF9hZGRfdGFpbCgmbWkt
Pm1ldGFsaXN0LCAmaWZlLT5tZXRhbGlzdCk7CisJc3Bpbl91bmxvY2tfYmgoJmlmZS0+dGNm
X2xvY2spOwogCiAJcmV0dXJuIHJldDsKIH0KQEAgLTM1Nyw3ICszNTUsNiBAQCBvdXRfbmxt
c2dfdHJpbToKIAlyZXR1cm4gLTE7CiB9CiAKLS8qIHVuZGVyIGlmZS0+dGNmX2xvY2sgKi8K
IHN0YXRpYyB2b2lkIF90Y2ZfaWZlX2NsZWFudXAoc3RydWN0IHRjX2FjdGlvbiAqYSwgaW50
IGJpbmQpCiB7CiAJc3RydWN0IHRjZl9pZmVfaW5mbyAqaWZlID0gYS0+cHJpdjsKQEAgLTM4
NSw3ICszODIsNiBAQCBzdGF0aWMgdm9pZCB0Y2ZfaWZlX2NsZWFudXAoc3RydWN0IHRjX2Fj
dGlvbiAqYSwgaW50IGJpbmQpCiAJc3Bpbl91bmxvY2tfYmgoJmlmZS0+dGNmX2xvY2spOwog
fQogCi0vKiB1bmRlciBpZmUtPnRjZl9sb2NrICovCiBzdGF0aWMgaW50IHBvcHVsYXRlX21l
dGFsaXN0KHN0cnVjdCB0Y2ZfaWZlX2luZm8gKmlmZSwgc3RydWN0IG5sYXR0ciAqKnRiKQog
ewogCWludCBsZW4gPSAwOwpAQCAtNDY1LDYgKzQ2MSw4IEBAIHN0YXRpYyBpbnQgdGNmX2lm
ZV9pbml0KHN0cnVjdCBuZXQgKm5ldCwgc3RydWN0IG5sYXR0ciAqbmxhLAogCX0KIAogCWlm
ZSA9IHRvX2lmZShhKTsKKwlpZiAoZXhpc3RzKQorCQlzcGluX2xvY2tfYmgoJmlmZS0+dGNm
X2xvY2spOwogCWlmZS0+ZmxhZ3MgPSBwYXJtLT5mbGFnczsKIAogCWlmIChwYXJtLT5mbGFn
cyAmIElGRV9FTkNPREUpIHsKQEAgLTQ3NSwxMCArNDczLDkgQEAgc3RhdGljIGludCB0Y2Zf
aWZlX2luaXQoc3RydWN0IG5ldCAqbmV0LCBzdHJ1Y3QgbmxhdHRyICpubGEsCiAJCQlzYWRk
ciA9IG5sYV9kYXRhKHRiW1RDQV9JRkVfU01BQ10pOwogCX0KIAotCXNwaW5fbG9ja19iaCgm
aWZlLT50Y2ZfbG9jayk7CiAJaWZlLT50Y2ZfYWN0aW9uID0gcGFybS0+YWN0aW9uOwotCiAJ
aWYgKHBhcm0tPmZsYWdzICYgSUZFX0VOQ09ERSkgeworCiAJCWlmIChkYWRkcikKIAkJCWV0
aGVyX2FkZHJfY29weShpZmUtPmV0aF9kc3QsIGRhZGRyKTsKIAkJZWxzZQpAQCAtNDkyLDYg
KzQ4OSw5IEBAIHN0YXRpYyBpbnQgdGNmX2lmZV9pbml0KHN0cnVjdCBuZXQgKm5ldCwgc3Ry
dWN0IG5sYXR0ciAqbmxhLAogCQlpZmUtPmV0aF90eXBlID0gaWZlX3R5cGU7CiAJfQogCisJ
aWYgKGV4aXN0cykKKwkJc3Bpbl91bmxvY2tfYmgoJmlmZS0+dGNmX2xvY2spOworCiAJaWYg
KHJldCA9PSBBQ1RfUF9DUkVBVEVEKQogCQlJTklUX0xJU1RfSEVBRCgmaWZlLT5tZXRhbGlz
dCk7CiAKQEAgLTUwNSw3ICs1MDUsNiBAQCBtZXRhZGF0YV9wYXJzZV9lcnI6CiAJCQlpZiAo
cmV0ID09IEFDVF9QX0NSRUFURUQpCiAJCQkJX3RjZl9pZmVfY2xlYW51cChhLCBiaW5kKTsK
IAotCQkJc3Bpbl91bmxvY2tfYmgoJmlmZS0+dGNmX2xvY2spOwogCQkJcmV0dXJuIGVycjsK
IAkJfQogCkBAIC01MjQsMTMgKzUyMywxMCBAQCBtZXRhZGF0YV9wYXJzZV9lcnI6CiAJCQlp
ZiAocmV0ID09IEFDVF9QX0NSRUFURUQpCiAJCQkJX3RjZl9pZmVfY2xlYW51cChhLCBiaW5k
KTsKIAotCQkJc3Bpbl91bmxvY2tfYmgoJmlmZS0+dGNmX2xvY2spOwogCQkJcmV0dXJuIGVy
cjsKIAkJfQogCX0KIAotCXNwaW5fdW5sb2NrX2JoKCZpZmUtPnRjZl9sb2NrKTsKLQogCWlm
IChyZXQgPT0gQUNUX1BfQ1JFQVRFRCkKIAkJdGNmX2hhc2hfaW5zZXJ0KHRuLCBhKTsKIAo=
--------------090309060501080801060007--
