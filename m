From: Dmitry Sytchev <kbdfck@gmail.com>
Subject: Re: Why do we prefer skb->priority to tc filters?
Date: Thu, 12 Mar 2015 11:53:25 +0400
Message-ID: <CA+GmxbbGHXrZ6OrwPm0WBzk89iK94wyzJJAqbqw_XbVELvy9nQ@mail.gmail.com>
References: <CAHA+R7Oz=Je_avfzjLib0YaQRUArEpt+sm1qNqcV_oEvUp3=eA@mail.gmail.com>
	<CAHA+R7Os6=uxTAYr=0ZrCKZpySNJ4QoT=mJa5daGJ_0zgD1Y7w@mail.gmail.com>
	<1426098340.11398.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Pa6ypGoUr5jJfbayzwjLA-C78NOa1iPmsbmx+wXP56AA@mail.gmail.com>
	<1426104582.11398.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M8EFF=y7LOqsiHMsT+Q1e+3wxAE93njkSk3p9nYc2gTA@mail.gmail.com>
	<1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:33063 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbbCLHx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 03:53:26 -0400
Received: by iecvj10 with SMTP id vj10so23551479iec.0
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 00:53:25 -0700 (PDT)
In-Reply-To: <1426110450.11398.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for slight offtopic, but for some reason, recent netfilter SET
changes, which allow setting queue number and priority via ipset
skbinfo extension, don't work with multiple HTB on top of multiq or
mq.
At the same time, tc filters set on outbound iface with skbedit works
fine both for prio and queue number.
How can I find the difference in their behaviour to trace where queue
number set by ipset match gets lost?

> Google definitely uses this model, as netfilter code runs on multiple
> cpus, while HTB classifier runs under qdisc spinlock, so far.
>
> If you believe root user should not set skb->priority to arbitrary
> values, this is a very different concern.



-- 
Best regards,

Dmitry Sytchev,
IT Engineer
