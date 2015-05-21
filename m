From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] codel: add ce_threshold support to codel &
 fc_codel
Date: Thu, 21 May 2015 15:25:28 -0700
Message-ID: <20150521152528.1791629f@urahara>
References: <1431366295.566.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35376 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756490AbbEUWZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:25:24 -0400
Received: by pdea3 with SMTP id a3so1609534pde.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 15:25:24 -0700 (PDT)
In-Reply-To: <1431366295.566.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 May 2015 10:44:55 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> codel & fq_codel packet schedulers are now able to have a threshold
> for CE marking packets, regardless of the drop/nodrop decision taken by
> CoDel.
> 
> This is particularly useful for dctcp and variants, that do not use
> traditional ECN.
> 
> Note that fq_codel users would have to specify noecn if ce_threshold is
> used, otherwise results would be not very interesting, as ecn is default
> on for fq_codel.
> 
> $ tc -s qdisc show dev eth1
> qdisc codel 8002: root refcnt 45 limit 1000p target 5.0ms ce_threshold
> 1.0ms interval 100.0ms 
>  Sent 4908469888317 bytes 3351813967 pkt (dropped 0, overlimits 0
> requeues 21624365) 
>  rate 37671Mbit 3231836pps backlog 4904740b 250p requeues 21624365 
>   count 0 lastcount 0 ldelay 1.1ms drop_next 0us
>   maxpacket 68130 ecn_mark 0 drop_overlimit 0 ce_mark 410861803
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next branch
