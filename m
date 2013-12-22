From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Sun, 22 Dec 2013 12:04:09 -0500
Message-ID: <52B71B89.2050603@mojatatu.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com> <52B60384.6000002@mojatatu.com> <52B712D3.9050605@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080501080107000105010203"
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:57109 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578Ab3LVREN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 12:04:13 -0500
Received: by mail-ig0-f180.google.com with SMTP id uq1so11456066igb.1
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 09:04:13 -0800 (PST)
In-Reply-To: <52B712D3.9050605@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080501080107000105010203
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 12/22/13 11:26, Jamal Hadi Salim wrote:

> BTW: This indev feature was supposed to be "temporary";->
> but has stuck around all these years. Not sure how widely it is
> used. I will send you a testcase shortly. If it passes for you
> please add my ACKed-by


Attached.
Please run before and after your changes and compare results.

cheers,
jamal

--------------080501080107000105010203
Content-Type: text/plain; charset=us-ascii;
 name="indev-test1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="indev-test1"

IwojCnN1ZG8gaWZjb25maWcgZHVtbXkwIHVwCiMKc3VkbyB0YyBxZGlzYyBkZWwgZGV2IGR1
bW15MCByb290IGhhbmRsZSAxOiBwcmlvCnN1ZG8gdGMgZmlsdGVyIGRlbCBkZXYgZHVtbXkw
IHByb3RvY29sIGlwIHByZWYgMSBwYXJlbnQgMTogaGFuZGxlIDEgZncKIwpzdWRvIHRjIHFk
aXNjIGFkZCBkZXYgZHVtbXkwIHJvb3QgaGFuZGxlIDE6IHByaW8KIwpzdWRvIHRjIGZpbHRl
ciBhZGQgZGV2IGR1bW15MCBwcm90b2NvbCBpcCBwcmVmIDEgcGFyZW50IDE6IGhhbmRsZSAx
IGZ3IFwKY2xhc3NpZCAxOjEgaW5kZXYgZXRoMCBcCmFjdGlvbiBkcm9wCiMKc3VkbyB0YyBm
aWx0ZXIgYWRkIGRldiBkdW1teTAgcHJvdG9jb2wgaXAgcHJlZiAyIHBhcmVudCAxOiBoYW5k
bGUgMSBmdyBcCmNsYXNzaWQgMToyIGluZGV2IGxvIFwKYWN0aW9uIG9rCiMtLSBjYXRjaCBh
bGwgLS0tCnN1ZG8gdGMgZmlsdGVyIGFkZCBkZXYgZHVtbXkwIHByb3RvY29sIGlwIHByZWYg
MyBwYXJlbnQgMTogaGFuZGxlIDEgZncgXApjbGFzc2lkIDE6MyBcCmFjdGlvbiBvawojCiMK
c3VkbyB0YyBxZGlzYyBkZWwgZGV2IGV0aDAgaW5ncmVzcwpzdWRvIHRjIHFkaXNjIGFkZCBk
ZXYgZXRoMCBpbmdyZXNzCnN1ZG8gdGMgcWRpc2MgZGVsIGRldiBsbyBpbmdyZXNzCnN1ZG8g
dGMgcWRpc2MgYWRkIGRldiBsbyBpbmdyZXNzCiMKc3VkbyB0YyBmaWx0ZXIgYWRkIGRldiBs
byBwYXJlbnQgZmZmZjogcHJvdG9jb2wgaXAgXAp1MzIgbWF0Y2ggaXAgcHJvdG9jb2wgMSAw
eGZmIFwKZmxvd2lkIDE6MSBcCmFjdGlvbiBza2JlZGl0IG1hcmsgMSBcCmFjdGlvbiBtaXJy
ZWQgZWdyZXNzIG1pcnJvciBkZXYgZHVtbXkwIAojCiMKc3VkbyB0YyBmaWx0ZXIgYWRkIGRl
diBldGgwIHBhcmVudCBmZmZmOiBwcm90b2NvbCBpcCBcCnUzMiBtYXRjaCBpcCBzcmMgOC44
LjguOC8zMiBcCmZsb3dpZCAxOjExIFwKYWN0aW9uIHNrYmVkaXQgbWFyayAxIFwKYWN0aW9u
IG1pcnJlZCBlZ3Jlc3MgbWlycm9yIGRldiBkdW1teTAgCiMgcGluZyAtYyAxIDEyNy4wLjAu
MQojIHBpbmcgLWMgMSA4LjguOC44CnN1ZG8gdGMgLXMgYWN0aW9ucyBscyBhY3Rpb24gc2ti
ZWRpdApzdWRvIHRjIC1zIGFjdGlvbnMgbHMgYWN0aW9uIG1pcnJlZApzdWRvIHRjIC1zIGFj
dGlvbnMgbHMgYWN0aW9uIGdhY3QKc3VkbyB0YyAtcyBmaWx0ZXIgbHMgZGV2IGR1bW15MCBw
YXJlbnQgMTogcHJvdG9jb2wgaXAgIApzdWRvIHRjIC1zIGZpbHRlciBscyBkZXYgZXRoMCBw
YXJlbnQgZmZmZjogcHJvdG9jb2wgaXAgIApzdWRvIHRjIC1zIGZpbHRlciBscyBkZXYgbG8g
cGFyZW50IGZmZmY6IHByb3RvY29sIGlwICAKIwojCg==
--------------080501080107000105010203--
