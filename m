From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [PATCH] Fix of wrong ipt debug messages
Date: Tue, 31 Aug 2004 16:50:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831165057.76ebd427.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__31_Aug_2004_16_50_57_-0700_IdZYm.D6Z.iKKEaH"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Tue__31_Aug_2004_16_50_57_-0700_IdZYm.D6Z.iKKEaH
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit



Begin forwarded message:

Date: Tue, 31 Aug 2004 18:42:05 +0400
From: Kirill Korotaev <kksx@mail.ru>
To: torvalds@osdl.org, akpm@osdl.org
Cc: linux-kernel@vger.kernel.org
Subject: [PATCH] Fix of wrong ipt debug messages


This patch fixes wrong ipt debug messages.
The problem is that when CONFIG_NETFILTER_DEBUG is set,
parp_redo() can flood debug output like this:

Mar 13 19:57:19 ts1 nf_hook: hook 0 already set.
Mar 13 19:57:19 ts1 skb: pf=0 (unowned) dev=eth0 len=46
.......

Kirill



--Multipart=_Tue__31_Aug_2004_16_50_57_-0700_IdZYm.D6Z.iKKEaH
Content-Type: application/octet-stream;
 name="diff-ipt-nfdbgarp-20030317"
Content-Disposition: attachment;
 filename="diff-ipt-nfdbgarp-20030317"
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNC4yMC0wMTl0ZXN0MDAyL25ldC9pcHY0L2FycC5jCVRodSBNYXIgMTMgMTM6
MTU6NTEgMjAwMworKysgbGludXgtMi40LjIwLTAxOXRlc3QwMDMvbmV0L2lwdjQvYXJwLmMJTW9u
IE1hciAxNyAxMzo0ODowOCAyMDAzCkBAIC01OTcsNiArNTk3LDkgQEAKIAogc3RhdGljIHZvaWQg
cGFycF9yZWRvKHN0cnVjdCBza19idWZmICpza2IpCiB7CisjaWYgZGVmaW5lZChDT05GSUdfTkVU
RklMVEVSKSAmJiBkZWZpbmVkKENPTkZJR19ORVRGSUxURVJfREVCVUcpCisJc2tiLT5uZl9kZWJ1
ZyA9IDA7CisjZW5kaWYKIAlhcnBfcmN2KHNrYiwgc2tiLT5kZXYsIE5VTEwpOwogfQogCg==

--Multipart=_Tue__31_Aug_2004_16_50_57_-0700_IdZYm.D6Z.iKKEaH--
