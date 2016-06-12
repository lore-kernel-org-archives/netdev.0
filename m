From: Toby DiPasquale <toby@cbcg.net>
Subject: Re: off-by-one in DecodeQ931
Date: Sun, 12 Jun 2016 19:29:44 -0400
Message-ID: <CAML0wpF0--_6kz_zSNrrz7XgWjtJ6JzULgZDKZULfQrghUqYaA@mail.gmail.com>
References: <CAML0wpEBwXdzWX7g3LDJRDOVM0J7dkuhH8b+96ZhRf54+qUgwQ@mail.gmail.com>
 <20160425152905.GA8621@strlen.de> <CAML0wpGWvcpB5GE_zAjOeO6ki_nszaj+hR9yyadwu_3hQno7Cg@mail.gmail.com>
 <CAML0wpGqddtn92Rb2CSmV0kZfTzOxdCU-+dAFG1HUAaqQa8RUw@mail.gmail.com>
 <20160606143555.GC7827@breakpoint.cc> <20160606145510.GB1168@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a1142738c97e2a805351d2554
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:35710 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbcFLX3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 19:29:45 -0400
Received: by mail-yw0-f173.google.com with SMTP id z186so94191889ywd.2
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2016 16:29:45 -0700 (PDT)
In-Reply-To: <20160606145510.GB1168@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a1142738c97e2a805351d2554
Content-Type: text/plain; charset=UTF-8

Attached is the patch generated with git format-patch.

On Mon, Jun 6, 2016 at 10:55 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Mon, Jun 06, 2016 at 04:35:55PM +0200, Florian Westphal wrote:
>> Toby DiPasquale <toby@cbcg.net> wrote:
>> > Is this latest patch OK?
>>
>> Yes, I don't know why it wasn't applied yet.
>>
>> Pablo?
>
> This doesn't apply.
>
> $ git am /tmp/off-by-one-in-DecodeQ931.patch -s
> Applying: off-by-one in DecodeQ931
> error: patch failed: net/netfilter/nf_conntrack_h323_asn1.c:846
> error: net/netfilter/nf_conntrack_h323_asn1.c: patch does not apply
> Patch failed at 0001 off-by-one in DecodeQ931
> The copy of the patch that failed is found in:
>    patch
> When you have resolved this problem, run "git am --continue".
> If you prefer to skip this patch, run "git am --skip" instead.
> To restore the original branch and stop patching, run "git am --abort".
>
> Could you resubmit using git-format-patch? Thanks.



-- 
Toby DiPasquale

--001a1142738c97e2a805351d2554
Content-Type: application/octet-stream; name="off-by-one.patch"
Content-Disposition: attachment; filename="off-by-one.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ipd83dgt0

RnJvbSAyY2FkYTVmZGNlMGVjZDViNDQ1YTM2MDkxNzQzMWNmMGRmZmZhNGJiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBUb2J5IERpUGFzcXVhbGUgPHRvYnlAY2JjZy5uZXQ+CkRhdGU6
IFN1biwgMTIgSnVuIDIwMTYgMTk6Mjc6NTMgLTA0MDAKU3ViamVjdDogW1BBVENIXSBmaXggb2Zm
LWJ5LW9uZSBpbiBEZWNvZGVROTMxCgotLS0KIG5ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX2gz
MjNfYXNuMS5jIHwgMyArKy0KIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDEgZGVs
ZXRpb24oLSkKCmRpZmYgLS1naXQgYS9uZXQvbmV0ZmlsdGVyL25mX2Nvbm50cmFja19oMzIzX2Fz
bjEuYyBiL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX2gzMjNfYXNuMS5jCmluZGV4IGJjZDVl
ZDYuLjg5YjJlNDYgMTAwNjQ0Ci0tLSBhL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX2gzMjNf
YXNuMS5jCisrKyBiL25ldC9uZXRmaWx0ZXIvbmZfY29ubnRyYWNrX2gzMjNfYXNuMS5jCkBAIC04
NDYsOSArODQ2LDEwIEBAIGludCBEZWNvZGVROTMxKHVuc2lnbmVkIGNoYXIgKmJ1Ziwgc2l6ZV90
IHN6LCBROTMxICpxOTMxKQogCXN6IC09IGxlbjsKIAogCS8qIE1lc3NhZ2UgVHlwZSAqLwotCWlm
IChzeiA8IDEpCisJaWYgKHN6IDwgMikKIAkJcmV0dXJuIEgzMjNfRVJST1JfQk9VTkQ7CiAJcTkz
MS0+TWVzc2FnZVR5cGUgPSAqcCsrOworCXN6LS07CiAJUFJJTlQoIk1lc3NhZ2VUeXBlID0gJTAy
WFxuIiwgcTkzMS0+TWVzc2FnZVR5cGUpOwogCWlmICgqcCAmIDB4ODApIHsKIAkJcCsrOwotLSAK
Mi43LjQKCg==
--001a1142738c97e2a805351d2554--
