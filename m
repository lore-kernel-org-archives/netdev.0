From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: add support for bytes_acked &
 bytes_received
Date: Thu, 21 May 2015 15:21:47 -0700
Message-ID: <20150521152147.090adfa4@urahara>
References: <1431363829.566.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35348 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161055AbbEUWVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 18:21:44 -0400
Received: by pdea3 with SMTP id a3so1520470pde.2
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 15:21:44 -0700 (PDT)
In-Reply-To: <1431363829.566.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 May 2015 10:03:49 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_info has 2 new fields : bytes_acked & bytes_received
> 
> $ ss -ti src :22
> ...
> 	 cubic wscale:7,6 rto:234 rtt:33.199/17.225 ato:17.225 mss:1418 cwnd:9
> ssthresh:9 send 3.1Mbps lastsnd:3 lastrcv:4 lastack:193
> bytes_acked:188396 bytes_received:13639 pacing_rate 6.2Mbps unacked:1
> retrans:0/4 reordering:4 rcv_rtt:47.25 rcv_space:28960
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next branch.
