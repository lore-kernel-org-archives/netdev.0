From: Rami Rosen <ramirose@gmail.com>
Subject: Re: [PATCH net-next-2.6] xfrm: cleanup of xfrm_input.c. (resend)
Date: Thu, 15 Jul 2010 08:21:03 +0300
Message-ID: <AANLkTim7fVRtycf2B07iI7U4chv2NqD267dvunZJYqPj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016368333a4cb75bb048b66442e
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36231 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab0GOFVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 01:21:08 -0400
Received: by wwi17 with SMTP id 17so2703861wwi.1
        for <netdev@vger.kernel.org>; Wed, 14 Jul 2010 22:21:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016368333a4cb75bb048b66442e
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

 Hi,
  The patch removes unneeded inclusion of header files
 (linux/module.h, linux/netdevice.h, net/dst.h and net/ip.h) and adds inclu=
sion
of linux/skbuff.h instead, in net/xfrm/xfrm_input.c.

 Regards,
 Rami Rosen


On Thu, Jul 15, 2010 at 3:59 AM, David Miller <davem@davemloft.net> wrote:
> From: Rami Rosen <ramirose@gmail.com>
> Date: Wed, 14 Jul 2010 11:18:41 +0300
>
>> Hi,
>> =A0The patch removes unneeded inclusion of header files
>> (linux/module.h, linux/netdevice.h, net/dst.h and net/ip.h)
>> =A0in net/xfrm/xfrm_input.c
>>
>> Regards,
>> Rami Rosen
>>
>> Signed-off-by: Rami Rosen <ramirose@gmail.com>
>
> If you do this, I also want to see you add includes for things like
> linux/skbuff.h since data structures such as "struct sk_buff"
> are used in this file.
>
> Otherwise, this is how we end up with obscure build failures on
> some configurations and not others, either now or in the future
> when a similar change is made to some header file.
>
>

--0016368333a4cb75bb048b66442e
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gbn5immb1

ZGlmZiAtLWdpdCBhL25ldC94ZnJtL3hmcm1faW5wdXQuYyBiL25ldC94ZnJtL3hmcm1faW5wdXQu
Yw0KaW5kZXggNDVmMWM5OC4uYzg3YWVjOCAxMDA2NDQNCi0tLSBhL25ldC94ZnJtL3hmcm1faW5w
dXQuYw0KKysrIGIvbmV0L3hmcm0veGZybV9pbnB1dC5jDQpAQCAtNiwxMiArNiw5IEBADQogICog
CQlTcGxpdCB1cCBhZi1zcGVjaWZpYyBwb3J0aW9uDQogICoNCiAgKi8NCi0NCisgDQorI2luY2x1
ZGUgPGxpbnV4L3NrYnVmZi5oPg0KICNpbmNsdWRlIDxsaW51eC9zbGFiLmg+DQotI2luY2x1ZGUg
PGxpbnV4L21vZHVsZS5oPg0KLSNpbmNsdWRlIDxsaW51eC9uZXRkZXZpY2UuaD4NCi0jaW5jbHVk
ZSA8bmV0L2RzdC5oPg0KLSNpbmNsdWRlIDxuZXQvaXAuaD4NCiAjaW5jbHVkZSA8bmV0L3hmcm0u
aD4NCiANCiBzdGF0aWMgc3RydWN0IGttZW1fY2FjaGUgKnNlY3BhdGhfY2FjaGVwIF9fcmVhZF9t
b3N0bHk7DQo=
--0016368333a4cb75bb048b66442e--
