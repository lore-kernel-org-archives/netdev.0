From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 15:05:17 -0700
Message-ID: <1411164317.26859.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	 <CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
	 <1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48002 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757728AbaISWFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 18:05:20 -0400
Received: by mail-pa0-f52.google.com with SMTP id hz1so910438pad.39
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 15:05:19 -0700 (PDT)
In-Reply-To: <CAHA+R7M=Wp1u1hXD9YE52Ct74KOovEaVjCECV_5EsrAO_rJ7ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 14:59 -0700, Cong Wang wrote:

> 
> Then fix these tx_queue_len = 0?

What are you suggesting exactly ?

We want them being 0, exactly.

This is the standard way many scripts are able to remove a qdisc.

We dont want to break user scripts. Ever.

tc qdisc add dev bond0 root sfq

...

ifconfig bond0 txqueuelen 0
tc qdisc del dev bond0 root

-> No qdisc
