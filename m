From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: display pacing_rate/max_pacing_rate
Date: Mon, 9 Jun 2014 12:39:15 -0700
Message-ID: <20140609123915.657e74ed@nehalam.linuxnetplumber.net>
References: <1401976057.3645.277.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:52095 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750878AbaFITsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:48:05 -0400
Received: by mail-pd0-f176.google.com with SMTP id p10so5179661pdj.7
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:48:05 -0700 (PDT)
In-Reply-To: <1401976057.3645.277.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Jun 2014 06:47:37 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Since linux-3.15, kernel exports tcpi_pacing_rate and
> tcpi_max_pacing_rate in tcp_info
> 
> Add TCP pacing_rate information on ss -i output :
> 
> lpaa23:~# ./ss -ti dst 10.246.7.151
> State      Recv-Q Send-Q   Local Address:Port       Peer Address:Port   
> ESTAB      0      325800    10.246.7.151:57614
> 10.246.7.152:46811   
> 	 cubic wscale:7,7 rto:201 rtt:0.081/0.006 mss:1448 cwnd:90 ssthresh:63
> send 12871.1Mbps pacing_rate 15397.8Mbps unacked:90 retrans:0/305
> rcv_space:29200
> 
> 
> If SO_MAX_PACING_RATE is set on the socket, we add /max_pacing_rate as
> in :
> 
> ... pacing_rate 1570.5Mbps/2.0Gbps ...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied
