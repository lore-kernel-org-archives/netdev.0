From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: next-20090318: sunhme does not transmit packets
Date: Tue, 24 Mar 2009 18:46:09 +0300
Message-ID: <a4423d670903240846j252a825cy1e8a50b5ac3a11ef@mail.gmail.com>
References: <a4423d670903180958j4847717eh99a41534633dd314@mail.gmail.com>
	 <20090318.234451.38898787.davem@davemloft.net>
	 <a4423d670903190116p157b2ebfl69d270e0576c6d9a@mail.gmail.com>
	 <20090322.215110.261185328.davem@davemloft.net>
	 <a4423d670903240432m1a4e8e08x9c97a0947d89800a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org,
	Kernel Testers List <kernel-testers@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Roel Kluin <roel.kluin@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761594AbZCXPq1@vger.kernel.org>
In-Reply-To: <a4423d670903240432m1a4e8e08x9c97a0947d89800a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/3/24 Alexander Beregalov <a.beregalov@gmail.com>:
>>> 2009/3/19 David Miller <davem@davemloft.net>:
>>> > Does the current vanilla kernel work fine?
>>>
>>> Yes. The problem happens only with -next tree.
>>
>> I have one of my ultra10s up and will try to reproduce and diagnose
>> this locally.
>
> Hi David
>
> 2.6.29 also does not work.
>
> The guilty patch should be between 2.6.29-rc8 and final 2.6.29
>
> even more narrow - 59fcbdd..v2.6.29
>
> I can try to bisect.

e4a389a9b5c892446b5de2038bdc0cca8703c615 is first bad commit
commit e4a389a9b5c892446b5de2038bdc0cca8703c615
Author: Roel Kluin <roel.kluin@gmail.com>
Date:   Wed Mar 18 23:12:13 2009 -0700

    net: kfree(napi->skb) => kfree_skb
