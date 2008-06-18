From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c.
Date: Wed, 18 Jun 2008 08:54:52 +0300
Message-ID: <eb3ff54b0806172254g678d3b08l56601420c057afb6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_47663_25356346.1213768492767"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:25296 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904AbYFRFyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 01:54:54 -0400
Received: by rv-out-0506.google.com with SMTP id k40so4398766rvb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 22:54:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_47663_25356346.1213768492767
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
Certainly!

In net/ipv6/tcp_ipv6.c:

 - Remove unneeded tcp_v6_send_check() declaration.


Regards,
Rami Rosen


On Wed, Jun 18, 2008 at 7:15 AM, David Miller <davem@davemloft.net> wrote:
> From: "Rami Rosen" <ramirose@gmail.com>
> Date: Tue, 17 Jun 2008 09:22:53 +0300
>
>> In net/ipv6/tcp_ipv6.c:
>>
>> 1) Remove unneeded tcp_v6_send_check() declaration.
>>
>> 2) Unify two consecutive #ifdef CONFIG_TCP_MD5SIG (with nothing in
>>   between them) into one #ifdef CONFIG_TCP_MD5SIG.
>>
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
>
> Rami, I was going to apply this to net-next-2.6
>
> The MD5 code changed a bit and in fact that
> sequence of local variables then code with ifdef
> protection isn't even there any more.
>
> Could you respin this patch against net-next-2.6,
> just the #1 part?
>
> Thanks!
>

------=_Part_47663_25356346.1213768492767
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhliccij0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3RjcF9pcHY2LmMgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5jCmlu
ZGV4IGRhZWZjMTguLjA5YmUwOWMgMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3RjcF9pcHY2LmMKKysr
IGIvbmV0L2lwdjYvdGNwX2lwdjYuYwpAQCAtNzAsOCArNzAsNiBAQAogCiBzdGF0aWMgdm9pZAl0
Y3BfdjZfc2VuZF9yZXNldChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpOwog
c3RhdGljIHZvaWQJdGNwX3Y2X3JlcXNrX3NlbmRfYWNrKHN0cnVjdCBza19idWZmICpza2IsIHN0
cnVjdCByZXF1ZXN0X3NvY2sgKnJlcSk7Ci1zdGF0aWMgdm9pZAl0Y3BfdjZfc2VuZF9jaGVjayhz
dHJ1Y3Qgc29jayAqc2ssIGludCBsZW4sCi0JCQkJICBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsKIAog
c3RhdGljIGludAl0Y3BfdjZfZG9fcmN2KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYg
KnNrYik7CiAK
------=_Part_47663_25356346.1213768492767--
