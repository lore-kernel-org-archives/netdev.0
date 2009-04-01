From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tx_queue_len question
Date: Wed, 1 Apr 2009 11:16:33 +0000
Message-ID: <20090401111633.GD5970@ff.dom.local>
References: <b0438a630903301049s7aa796b5t1658999bd4ee1f69@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: =?us-ascii?B?PT9JU08tODg1OS0yP1E/TWlndWVsXz1DMW5nZWxfPUMxbHZhcmV6Pz0=?=
	<gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:4427 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbZDALQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 07:16:44 -0400
Received: by rv-out-0506.google.com with SMTP id f9so3579914rvb.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2009 04:16:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b0438a630903301049s7aa796b5t1658999bd4ee1f69@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-03-2009 18:49, Miguel =C1ngel =C1lvarez wrote:
> Hi
>=20
> Could anyone please tell me how tx_queue_len works? (Or where to take
> a look to?).

Maybe net/sched/sch_generic.c: pfifo_fast_enqueue()?

>=20
> I am facing two problems with it:
> - Using ixp4xx_hss driver, I am not in the same situation if I let th=
e
> driver chose tx_queue_len in the initialization, or if I use ifconfig
> with the same value (100). With the last it seems to be capable of
> storing more frames.

This shouldn't matter unless I miss something.

> - When I increment it to 300 using ifconfig, the behaviour seems to b=
e
> worse than in the case of 100 or 200. Which are the litis of the
> value?

Except some special cases there is used a common value for a similar
class of devices, like in ether_setup(). The behaviour should depend
on the kind of traffic.

Jarek P.
