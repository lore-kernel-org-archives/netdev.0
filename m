From: Cong Wang <amwang@redhat.com>
Subject: Re: [V4 PATCH 3/3] bond: service netpoll arp queue on master device
Date: Mon, 28 Feb 2011 11:32:18 +0800
Message-ID: <4D6B1742.6030108@redhat.com>
References: <1298022215-21059-1-git-send-email-amwang@redhat.com>	<1298022215-21059-3-git-send-email-amwang@redhat.com> <20110227.161225.200373200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000104060508000508040909"
Cc: linux-kernel@vger.kernel.org, nhorman@redhat.com,
	herbert@gondor.hengli.com.au, nhorman@tuxdriver.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110227.161225.200373200.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000104060508000508040909
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

于 2011年02月28日 08:12, David Miller 写道:
> From: Amerigo Wang<amwang@redhat.com>
> Date: Fri, 18 Feb 2011 17:43:34 +0800
>
>> Neil pointed out that we can't send ARP reply on behalf of slaves,
>> we need to move the arp queue to their bond device.
>>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>
> Applied.

Oops! Just found that this one I sent was not a refreshed patch.
Please discard this one, and use the one below, that is the
correct one in my git tree and the one that I tested.

Sorry for this.

----

Signed-off-by: WANG Cong <amwang@redhat.com>

--------------000104060508000508040909
Content-Type: text/plain;
 name="bond-move-arp-queue-to-master.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="bond-move-arp-queue-to-master.diff"

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL25ldHBvbGwuYyBiL25ldC9jb3JlL25ldHBvbGwuYwpp
bmRleCBmNjhlNjk0Li4wNmJlMjQzIDEwMDY0NAotLS0gYS9uZXQvY29yZS9uZXRwb2xsLmMK
KysrIGIvbmV0L2NvcmUvbmV0cG9sbC5jCkBAIC0xOTMsNiArMTkzLDE3IEBAIHZvaWQgbmV0
cG9sbF9wb2xsX2RldihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2KQogCiAJcG9sbF9uYXBpKGRl
dik7CiAKKwlpZiAoZGV2LT5wcml2X2ZsYWdzICYgSUZGX1NMQVZFKSB7CisJCWlmIChkZXYt
Pm5waW5mbykgeworCQkJc3RydWN0IG5ldF9kZXZpY2UgKmJvbmRfZGV2ID0gZGV2LT5tYXN0
ZXI7CisJCQlzdHJ1Y3Qgc2tfYnVmZiAqc2tiOworCQkJd2hpbGUgKChza2IgPSBza2JfZGVx
dWV1ZSgmZGV2LT5ucGluZm8tPmFycF90eCkpKSB7CisJCQkJc2tiLT5kZXYgPSBib25kX2Rl
djsKKwkJCQlza2JfcXVldWVfdGFpbCgmYm9uZF9kZXYtPm5waW5mby0+YXJwX3R4LCBza2Ip
OworCQkJfQorCQl9CisJfQorCiAJc2VydmljZV9hcnBfcXVldWUoZGV2LT5ucGluZm8pOwog
CiAJemFwX2NvbXBsZXRpb25fcXVldWUoKTsK
--------------000104060508000508040909--
