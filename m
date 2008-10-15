From: "Manish Katiyar" <mkatiyar@gmail.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/802/fc.c
Date: Wed, 15 Oct 2008 12:33:03 +0530
Message-ID: <ea11fea30810150003l67f8edb2k8cfec9c8c6a48345@mail.gmail.com>
References: <20081014193500.GA6502@joi>
	 <20081014.163620.23535849.davem@davemloft.net>
	 <ea11fea30810142036i22d02a32i571fc0ea7c0e2dff@mail.gmail.com>
	 <20081014.231749.251795830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_27276_20859080.1224054183361"
Cc: marcin.slusarz@gmail.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:40456 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbYJOHDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 03:03:05 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1419137tic.23
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2008 00:03:03 -0700 (PDT)
In-Reply-To: <20081014.231749.251795830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_27276_20859080.1224054183361
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wed, Oct 15, 2008 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
> From: "Manish Katiyar" <mkatiyar@gmail.com>
> Date: Wed, 15 Oct 2008 09:06:12 +0530
>
>> Updated the below patch as per suggestions.
>>
>> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
>>
>
> Your email client corrupted the patch, changing tabs into
> spaces and breaking up long lines.  This makes the patch
> not usable.

I had already set the mail client to avoid such issues :-(. Attached
the patch with the mail. Will that help ? or do I need to send again
in the mail body itself ?

Thanks -
Manish


>
> Please fix this up and resubmit, thanks.
>

------=_Part_27276_20859080.1224054183361
Content-Type: text/x-diff; name=0015-Fix-compilation-warnings.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fmbm6vpj0
Content-Disposition: attachment;
 filename=0015-Fix-compilation-warnings.patch

RnJvbSBiMjM1NzA1YzMzYTJjMzRjNmQzYmIyMjVkMDVmOTRlMDgzOGZhMDU3IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNYW5pc2ggS2F0aXlhciA8bWthdGl5YXJAZ21haWwuY29tPgpE
YXRlOiBXZWQsIDE1IE9jdCAyMDA4IDA5OjA2OjExICswNTMwClN1YmplY3Q6IFtQQVRDSF0gRml4
IGNvbXBpbGF0aW9uIHdhcm5pbmdzCgoKU2lnbmVkLW9mZi1ieTogTWFuaXNoIEthdGl5YXIgPG1r
YXRpeWFyQGdtYWlsLmNvbT4KLS0tCiBuZXQvODAyL2ZjLmMgfCAgICAyICstCiAxIGZpbGVzIGNo
YW5nZWQsIDEgaW5zZXJ0aW9ucygrKSwgMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9uZXQv
ODAyL2ZjLmMgYi9uZXQvODAyL2ZjLmMKaW5kZXggY2IzNDc1ZS4uMzRjZjFlZSAxMDA2NDQKLS0t
IGEvbmV0LzgwMi9mYy5jCisrKyBiL25ldC84MDIvZmMuYwpAQCAtODIsMTMgKzgyLDEzIEBAIHN0
YXRpYyBpbnQgZmNfaGVhZGVyKHN0cnVjdCBza19idWZmICpza2IsIHN0cnVjdCBuZXRfZGV2aWNl
ICpkZXYsCiAKIHN0YXRpYyBpbnQgZmNfcmVidWlsZF9oZWFkZXIoc3RydWN0IHNrX2J1ZmYgKnNr
YikKIHsKKyNpZmRlZiBDT05GSUdfSU5FVAogCXN0cnVjdCBmY2hfaGRyICpmY2g9KHN0cnVjdCBm
Y2hfaGRyICopc2tiLT5kYXRhOwogCXN0cnVjdCBmY2xsYyAqZmNsbGM9KHN0cnVjdCBmY2xsYyAq
KShza2ItPmRhdGErc2l6ZW9mKHN0cnVjdCBmY2hfaGRyKSk7CiAJaWYoZmNsbGMtPmV0aGVydHlw
ZSAhPSBodG9ucyhFVEhfUF9JUCkpIHsKIAkJcHJpbnRrKCJmY19yZWJ1aWxkX2hlYWRlcjogRG9u
J3Qga25vdyBob3cgdG8gcmVzb2x2ZSB0eXBlICUwNFggYWRkcmVzc2VzID9cbiIsIG50b2hzKGZj
bGxjLT5ldGhlcnR5cGUpKTsKIAkJcmV0dXJuIDA7CiAJfQotI2lmZGVmIENPTkZJR19JTkVUCiAJ
cmV0dXJuIGFycF9maW5kKGZjaC0+ZGFkZHIsIHNrYik7CiAjZWxzZQogCXJldHVybiAwOwotLSAK
MS41LjQuMwoK
------=_Part_27276_20859080.1224054183361--
