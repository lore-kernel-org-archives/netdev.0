From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 07:18:26 +0200
Message-ID: <1271395106.16881.3645.camel@edumazet-laptop>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271268242.16881.1719.camel@edumazet-laptop>
	 <1271271222.4567.51.camel@bigi>
	 <20100415.014857.168270765.davem@davemloft.net>
	 <1271332528.4567.150.camel@bigi>  <4BC741AE.3000108@hp.com>
	 <1271362581.23780.12.camel@bigi>
	 <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:50111 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752629Ab0DPFSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 01:18:37 -0400
Received: by bwz25 with SMTP id 25so2533879bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 22:18:35 -0700 (PDT)
In-Reply-To: <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 07:56 +0800, Changli Gao a =C3=A9crit =
:
> On Fri, Apr 16, 2010 at 4:16 AM, jamal <hadi@cyberus.ca> wrote:
> >
> > Sounds interesting.
> > Wikipedia information overload. Any arch description of the HP9000?
> > Did your scheme use IPIs to message the other CPUs?
> >
>=20
> If you doubt the cost of smp_call_function_single(), how about having
> a try with my another patch, which implements the similar of RPS, but
> uses kernel threads instead, so no explicit IPI.
>=20
> http://patchwork.ozlabs.org/patch/38319/
>=20
>=20

Come on Changli.

How do you wake up a thread on a remote cpu ?

To answer Jamal question, we need to answer to Jamal question, that is
timing cost of IPIS.

A kernel module might do this, this could be integrated in perf bench s=
o
that we can regression tests upcoming kernels.



