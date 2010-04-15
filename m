From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 07:51:45 +0800
Message-ID: <u2x412e6f7f1004151651pdcc3414fsdcb4a25ecc0eeee3@mail.gmail.com>
References: <1265568122.3688.36.camel@bigi> <1271271222.4567.51.camel@bigi>
	<20100414124426.6aee95c3@nehalam> <1271276568.4567.59.camel@bigi>
	<1271276855.16881.1756.camel@edumazet-laptop> <z2y65634d661004141345o9bdcf759sf266866931823baf@mail.gmail.com>
	<1271278661.16881.1761.camel@edumazet-laptop> <1271333428.23780.3.camel@bigi>
	<s2p412e6f7f1004150532y4b13a0bfgadab3e6f2f4aecd@mail.gmail.com>
	<1271335844.23780.8.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:40574 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756638Ab0DOXwF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 19:52:05 -0400
Received: by iwn35 with SMTP id 35so959506iwn.21
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 16:52:05 -0700 (PDT)
In-Reply-To: <1271335844.23780.8.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 15, 2010 at 8:50 PM, jamal <hadi@cyberus.ca> wrote:
> On Thu, 2010-04-15 at 20:32 +0800, Changli Gao wrote:
>
>> For historical reason, we use Linux-2.6.18. Our company have several
>> products with CPU Xen, P4, or i7. Some of them are SMP, Multi-Core a=
nd
>> Multi-Threaded.
>
> Thanks for sharing. How much more can you say? ;-> Do you have a pape=
r
> or description of some sort somewhere?

On a dual 4-core Xeon, we use one core for NIC in internal side, one
core for NIC in the external side, one for inbound QoS, one for
outbound QoS, and the CPU cycles left are used by DPI(DFA), the total
throughput is about 3 Gbps with a polygraph test.

>
>> We use the similar mechanism like dynamic weighted
>> RPS. The total throughput is increased nearly linear with the number
>> of the worker threads(one worker thread per CPU).
>
> Other than the i7 - have you tried to run rps on on the P4?
>

No.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
