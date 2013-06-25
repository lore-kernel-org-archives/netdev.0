From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: add more TCP_INFO components
Date: Tue, 25 Jun 2013 13:33:52 -0700
Message-ID: <20130625133352.6d10797a@nehalam.linuxnetplumber.net>
References: <1372192157.3301.118.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:58865 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753543Ab3FYUd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 16:33:57 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so13197133pad.18
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 13:33:57 -0700 (PDT)
In-Reply-To: <1372192157.3301.118.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jun 2013 13:29:17 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Allow ss -i to display more TCP informations :
> 
> unacked:N   Number of un-acked packets
> retrans:X/Y   X: number of outstanding retransmit packets
>               Y: total number of retransmits for the session
> lost:N       Number of lost packets (tcpi_lost)
> sacked:N     Number of sacked packets (tcpi_sacked)
> facked:N     Number of facked packets (tcpi_facked)
> reordering:N Reordering level (if different of 3)
> 
> Example :
> 
> $ ss -emoi dst 10.7.7.83
> tcp   ESTAB      0      1154056   10.7.7.84:54127    10.7.7.83:34342
> timer:(on,200ms,0) ino:57003 sk:ffff88063c51d0c0 <->
> 	 skmem:(r0,rb89280,t0,tb2097152,f726504,w1436184,o0,bl0) ts sack cubic
> wscale:7,6 rto:310 rtt:107.375/1 mss:1448 cwnd:568 ssthresh:108 send
> 61.3Mbps unacked:568 retrans:0/21 reordering:127 rcv_space:29200
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Applied
