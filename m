From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 07:56:28 +0800
Message-ID: <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271268242.16881.1719.camel@edumazet-laptop> <1271271222.4567.51.camel@bigi>
	<20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi>
	<4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org, robert@herjulf.net,
	andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:48013 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758042Ab0DOX4w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 19:56:52 -0400
Received: by gyg13 with SMTP id 13so1032204gyg.19
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:56:51 -0700 (PDT)
In-Reply-To: <1271362581.23780.12.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 4:16 AM, jamal <hadi@cyberus.ca> wrote:
>
> Sounds interesting.
> Wikipedia information overload. Any arch description of the HP9000?
> Did your scheme use IPIs to message the other CPUs?
>

If you doubt the cost of smp_call_function_single(), how about having
a try with my another patch, which implements the similar of RPS, but
uses kernel threads instead, so no explicit IPI.

http://patchwork.ozlabs.org/patch/38319/


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
