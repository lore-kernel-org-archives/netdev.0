From: Cong Wang <cwang@twopensource.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Thu, 12 Mar 2015 10:25:56 -0700
Message-ID: <CAHA+R7MTjFWbi=Fex6GhZVfjHNHhSH6DV7ov2UOfxYmo6QCH2g@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	<CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	<1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	<1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
	<1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7N88DFPpfPeN5cqru7oODfew1ZUdT80R0fj1QkQsx-siw@mail.gmail.com>
	<1426118427.11398.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7MHptw8gbA6nqPYzc2vSGEunwKTJmL6kJ81820c7oc6BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:34816 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038AbbCLRZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 13:25:57 -0400
Received: by ieclw3 with SMTP id lw3so50830827iec.2
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 10:25:57 -0700 (PDT)
In-Reply-To: <CAHA+R7MHptw8gbA6nqPYzc2vSGEunwKTJmL6kJ81820c7oc6BQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 9:59 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Wed, Mar 11, 2015 at 5:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> If you use mavclan or ipvlan, not all paths will use __dev_forward_skb()
>>
>
> That is intentional, because I am not sure about stacked device
> like macvlan or tunnel, it might make some sense to keep that value.
>
>> So I am guessing you use veth maybe. Who knows.
>>
>
>
> Exactly, otherwise I would probably just change skb_scrub_packet(). ;)

Ok, in some mode macvlan forwards the packets to Rx path too, interesting...
