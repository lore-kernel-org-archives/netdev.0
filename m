From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_nat: get the position info from skb->tc_verd
Date: Fri, 30 Jul 2010 10:57:43 +0800
Message-ID: <AANLkTinYeJ+RDPCt4O6jKFVjYXCcQs7E7bCAO862jVQj@mail.gmail.com>
References: <1280428952-14151-1-git-send-email-xiaosuo@gmail.com>
	<20100730023649.GA5798@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61282 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716Ab0G3C6G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 22:58:06 -0400
Received: by wyb39 with SMTP id 39so762908wyb.19
        for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 19:58:03 -0700 (PDT)
In-Reply-To: <20100730023649.GA5798@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 30, 2010 at 10:36 AM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Fri, Jul 30, 2010 at 02:42:32AM +0800, Changli Gao wrote:
>> act_nat uses its flags field to determine where it acts. It isn't re=
liable,
>> and can't prevent users from doing wrong settings, and act_nat shoul=
d get the
>> position info from skb->tc_verd as act_mirred does.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Nack, the direction controls whether we NAT saddr or daddr. =A0It's
> perfectly OK for someone to NAT daddr on the way out.
>

Thanks for your explanation. However, ingress and egress aren't as
comprehensive as DNAT and SNAT. BTW I am planning to add stateless
PAT(Port Address Translation) support into act_nat. Any comment?

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
