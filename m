From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: tc rsvp filter show broke
Date: Sun, 28 Sep 2014 10:15:17 -0700
Message-ID: <CAM_iQpXzXHc7o1WOtkNnF+io_WZFP+DP4zWm8PZbwX7SC38=Pw@mail.gmail.com>
References: <5425A545.1040907@gmail.com>
	<5425ED2D.1000005@mojatatu.com>
	<5425F5CC.4070507@intel.com>
	<542823CE.9020301@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec547cb7d4d893f0504234b42
Cc: John Fastabend <john.r.fastabend@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:53544 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbaI1RPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 13:15:18 -0400
Received: by mail-vc0-f172.google.com with SMTP id lf12so685145vcb.17
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 10:15:17 -0700 (PDT)
In-Reply-To: <542823CE.9020301@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--bcaec547cb7d4d893f0504234b42
Content-Type: text/plain; charset=UTF-8

On Sun, Sep 28, 2014 at 8:05 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 09/26/14 19:25, John Fastabend wrote:
>>
>> On 09/26/2014 03:48 PM, Jamal Hadi Salim wrote:
>
>
>>> Hrm  - poking inside there and this seems to be one of those
>>> classifiers that hasnt been getting a lot of love. Doesnt
>>> support actions well for example.
>>>
>>> It seems to work for me:
>>
>>
>> This works for me as well try adding two or more policers and
>> check if they all get printed.
>>
>
> Multiple actions wont work for this classifier. I have time,
> will send patch.
>

Hmm, looks like there is a bug in police dump. Please
try the attached patch.

Thanks.

--bcaec547cb7d4d893f0504234b42
Content-Type: text/plain; charset=US-ASCII; name="cls-fix.diff"
Content-Disposition: attachment; filename="cls-fix.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i0mne2kb0

ZGlmZiAtLWdpdCBhL25ldC9zY2hlZC9jbHNfYXBpLmMgYi9uZXQvc2NoZWQvY2xzX2FwaS5jCmlu
ZGV4IGMyOGIwZDMuLjEyMTg5MDAgMTAwNjQ0Ci0tLSBhL25ldC9zY2hlZC9jbHNfYXBpLmMKKysr
IGIvbmV0L3NjaGVkL2Nsc19hcGkuYwpAQCAtNTc2LDE2ICs1NzYsMTggQEAgaW50IHRjZl9leHRz
X2R1bXAoc3RydWN0IHNrX2J1ZmYgKnNrYiwgc3RydWN0IHRjZl9leHRzICpleHRzKQogCQkJaWYg
KHRjZl9hY3Rpb25fZHVtcChza2IsICZleHRzLT5hY3Rpb25zLCAwLCAwKSA8IDApCiAJCQkJZ290
byBubGFfcHV0X2ZhaWx1cmU7CiAJCQlubGFfbmVzdF9lbmQoc2tiLCBuZXN0KTsKLQkJfSBlbHNl
IGlmIChleHRzLT5wb2xpY2UpIHsKLQkJCXN0cnVjdCB0Y19hY3Rpb24gKmFjdCA9IHRjZl9leHRz
X2ZpcnN0X2FjdChleHRzKTsKLQkJCW5lc3QgPSBubGFfbmVzdF9zdGFydChza2IsIGV4dHMtPnBv
bGljZSk7Ci0JCQlpZiAobmVzdCA9PSBOVUxMIHx8ICFhY3QpCi0JCQkJZ290byBubGFfcHV0X2Zh
aWx1cmU7Ci0JCQlpZiAodGNmX2FjdGlvbl9kdW1wX29sZChza2IsIGFjdCwgMCwgMCkgPCAwKQot
CQkJCWdvdG8gbmxhX3B1dF9mYWlsdXJlOwotCQkJbmxhX25lc3RfZW5kKHNrYiwgbmVzdCk7CiAJ
CX0KIAl9CisKKwlpZiAoZXh0cy0+cG9saWNlKSB7CisJCXN0cnVjdCB0Y19hY3Rpb24gKmFjdCA9
IHRjZl9leHRzX2ZpcnN0X2FjdChleHRzKTsKKwkJbmVzdCA9IG5sYV9uZXN0X3N0YXJ0KHNrYiwg
ZXh0cy0+cG9saWNlKTsKKwkJaWYgKG5lc3QgPT0gTlVMTCB8fCAhYWN0KQorCQkJZ290byBubGFf
cHV0X2ZhaWx1cmU7CisJCWlmICh0Y2ZfYWN0aW9uX2R1bXBfb2xkKHNrYiwgYWN0LCAwLCAwKSA8
IDApCisJCQlnb3RvIG5sYV9wdXRfZmFpbHVyZTsKKwkJbmxhX25lc3RfZW5kKHNrYiwgbmVzdCk7
CisJfQogCXJldHVybiAwOwogCiBubGFfcHV0X2ZhaWx1cmU6Cg==
--bcaec547cb7d4d893f0504234b42--
