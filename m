From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/2] act_mirred: cleanup
Date: Tue, 17 Nov 2009 13:48:06 +0800
Message-ID: <412e6f7f0911162148g72eb3749g860e476b7b5f3ab6@mail.gmail.com>
References: <412e6f7f0911160033h649b44b2o669196b8b14bf6fc@mail.gmail.com>
	 <1258363479.3251.25.camel@bigi>
	 <20091116.024824.267061616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=000e0cd32e2e955d4b04788aabb7
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:64831 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbZKQFsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 00:48:00 -0500
Received: by pxi10 with SMTP id 10so1690973pxi.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 21:48:06 -0800 (PST)
In-Reply-To: <20091116.024824.267061616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--000e0cd32e2e955d4b04788aabb7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 16, 2009 at 6:48 PM, David Miller <davem@davemloft.net> wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Mon, 16 Nov 2009 04:24:39 -0500
>
>> On Mon, 2009-11-16 at 16:33 +0800, Changli Gao wrote:
>>> act_mirred: cleanup
>>>
>>> 1. don't let go back using goto.
>>> 2. don't call skb_act_clone() until it is necessary.
>>> 3. one exit of the critical context.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>
>> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
>
> Applied.
>

Patch is resubmitted as attachment.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)

--000e0cd32e2e955d4b04788aabb7
Content-Type: application/octet-stream; name="act_mirred_cleanup.diff"
Content-Disposition: attachment; filename="act_mirred_cleanup.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g248rx7l0

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9hY3RfbWlycmVkLmMgYi9uZXQvc2NoZWQvYWN0X21pcnJl
ZC5jCmluZGV4IGI5YWFhYjQuLmI4MTJjMjAgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9hY3RfbWly
cmVkLmMKKysrIGIvbmV0L3NjaGVkL2FjdF9taXJyZWQuYwpAQCAtMTQ4LDQ3ICsxNDgsMzkgQEAg
c3RhdGljIGludCB0Y2ZfbWlycmVkKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCB0Y19hY3Rp
b24gKmEsCiB7CiAJc3RydWN0IHRjZl9taXJyZWQgKm0gPSBhLT5wcml2OwogCXN0cnVjdCBuZXRf
ZGV2aWNlICpkZXY7Ci0Jc3RydWN0IHNrX2J1ZmYgKnNrYjIgPSBOVUxMOwotCXUzMiBhdCA9IEdf
VENfQVQoc2tiLT50Y192ZXJkKTsKKwlzdHJ1Y3Qgc2tfYnVmZiAqc2tiMjsKKwl1MzIgYXQ7CisJ
aW50IHJldHZhbCwgZXJyID0gMTsKIAogCXNwaW5fbG9jaygmbS0+dGNmX2xvY2spOwotCi0JZGV2
ID0gbS0+dGNmbV9kZXY7CiAJbS0+dGNmX3RtLmxhc3R1c2UgPSBqaWZmaWVzOworCWlmIChtLT50
Y2ZtX2VhY3Rpb24gIT0gVENBX0VHUkVTU19NSVJST1IgJiYKKwkgICAgbS0+dGNmbV9lYWN0aW9u
ICE9IFRDQV9FR1JFU1NfUkVESVIpIHsKKwkJaWYgKG5ldF9yYXRlbGltaXQoKSkKKwkJCXByaW50
aygidGNmX21pcnJlZCB1bmtub3duIGFjdGlvbiAlZFxuIiwKKwkJCSAgICAgICBtLT50Y2ZtX2Vh
Y3Rpb24pOworCQlnb3RvIG91dDsKKwl9CiAKLQlpZiAoIShkZXYtPmZsYWdzJklGRl9VUCkgKSB7
CisJZGV2ID0gbS0+dGNmbV9kZXY7CisJaWYgKCEoZGV2LT5mbGFncyAmIElGRl9VUCkpIHsKIAkJ
aWYgKG5ldF9yYXRlbGltaXQoKSkKIAkJCXByaW50aygibWlycmVkIHRvIEhvdXN0b246IGRldmlj
ZSAlcyBpcyBnb25lIVxuIiwKIAkJCSAgICAgICBkZXYtPm5hbWUpOwotYmFkX21pcnJlZDoKLQkJ
aWYgKHNrYjIgIT0gTlVMTCkKLQkJCWtmcmVlX3NrYihza2IyKTsKLQkJbS0+dGNmX3FzdGF0cy5v
dmVybGltaXRzKys7Ci0JCW0tPnRjZl9ic3RhdHMuYnl0ZXMgKz0gcWRpc2NfcGt0X2xlbihza2Ip
OwotCQltLT50Y2ZfYnN0YXRzLnBhY2tldHMrKzsKLQkJc3Bpbl91bmxvY2soJm0tPnRjZl9sb2Nr
KTsKLQkJLyogc2hvdWxkIHdlIGJlIGFza2luZyBmb3IgcGFja2V0IHRvIGJlIGRyb3BwZWQ/Ci0J
CSAqIG1heSBtYWtlIHNlbnNlIGZvciByZWRpcmVjdCBjYXNlIG9ubHkKLQkJKi8KLQkJcmV0dXJu
IFRDX0FDVF9TSE9UOworCQlnb3RvIG91dDsKIAl9CiAKIAlza2IyID0gc2tiX2FjdF9jbG9uZShz
a2IsIEdGUF9BVE9NSUMpOwogCWlmIChza2IyID09IE5VTEwpCi0JCWdvdG8gYmFkX21pcnJlZDsK
LQlpZiAobS0+dGNmbV9lYWN0aW9uICE9IFRDQV9FR1JFU1NfTUlSUk9SICYmCi0JICAgIG0tPnRj
Zm1fZWFjdGlvbiAhPSBUQ0FfRUdSRVNTX1JFRElSKSB7Ci0JCWlmIChuZXRfcmF0ZWxpbWl0KCkp
Ci0JCQlwcmludGsoInRjZl9taXJyZWQgdW5rbm93biBhY3Rpb24gJWRcbiIsCi0JCQkgICAgICAg
bS0+dGNmbV9lYWN0aW9uKTsKLQkJZ290byBiYWRfbWlycmVkOwotCX0KKwkJZ290byBvdXQ7CiAK
IAltLT50Y2ZfYnN0YXRzLmJ5dGVzICs9IHFkaXNjX3BrdF9sZW4oc2tiMik7CiAJbS0+dGNmX2Jz
dGF0cy5wYWNrZXRzKys7Ci0JaWYgKCEoYXQgJiBBVF9FR1JFU1MpKQorCWF0ID0gR19UQ19BVChz
a2ItPnRjX3ZlcmQpOworCWlmICghKGF0ICYgQVRfRUdSRVNTKSkgewogCQlpZiAobS0+dGNmbV9v
a19wdXNoKQogCQkJc2tiX3B1c2goc2tiMiwgc2tiMi0+ZGV2LT5oYXJkX2hlYWRlcl9sZW4pOwor
CX0KIAogCS8qIG1pcnJvciBpcyBhbHdheXMgc3dhbGxvd2VkICovCiAJaWYgKG0tPnRjZm1fZWFj
dGlvbiAhPSBUQ0FfRUdSRVNTX01JUlJPUikKQEAgLTE5Nyw4ICsxODksMjMgQEAgYmFkX21pcnJl
ZDoKIAlza2IyLT5kZXYgPSBkZXY7CiAJc2tiMi0+aWlmID0gc2tiLT5kZXYtPmlmaW5kZXg7CiAJ
ZGV2X3F1ZXVlX3htaXQoc2tiMik7CisJZXJyID0gMDsKKworb3V0OgorCWlmIChlcnIpIHsKKwkJ
bS0+dGNmX3FzdGF0cy5vdmVybGltaXRzKys7CisJCW0tPnRjZl9ic3RhdHMuYnl0ZXMgKz0gcWRp
c2NfcGt0X2xlbihza2IpOworCQltLT50Y2ZfYnN0YXRzLnBhY2tldHMrKzsKKwkJLyogc2hvdWxk
IHdlIGJlIGFza2luZyBmb3IgcGFja2V0IHRvIGJlIGRyb3BwZWQ/CisJCSAqIG1heSBtYWtlIHNl
bnNlIGZvciByZWRpcmVjdCBjYXNlIG9ubHkKKwkJICovCisJCXJldHZhbCA9IFRDX0FDVF9TSE9U
OworCX0gZWxzZSB7CisJCXJldHZhbCA9IG0tPnRjZl9hY3Rpb247CisJfQogCXNwaW5fdW5sb2Nr
KCZtLT50Y2ZfbG9jayk7Ci0JcmV0dXJuIG0tPnRjZl9hY3Rpb247CisKKwlyZXR1cm4gcmV0dmFs
OwogfQogCiBzdGF0aWMgaW50IHRjZl9taXJyZWRfZHVtcChzdHJ1Y3Qgc2tfYnVmZiAqc2tiLCBz
dHJ1Y3QgdGNfYWN0aW9uICphLCBpbnQgYmluZCwgaW50IHJlZikK
--000e0cd32e2e955d4b04788aabb7--
