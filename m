From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: add SK_MEMINFO_DROPS display
Date: Fri, 22 Apr 2016 10:21:26 -0700
Message-ID: <20160422102126.5a811454@xeon-e3>
References: <1461241144.7627.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34466 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357AbcDVRVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 13:21:15 -0400
Received: by mail-pa0-f47.google.com with SMTP id r5so37598000pag.1
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 10:21:15 -0700 (PDT)
In-Reply-To: <1461241144.7627.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Apr 2016 05:19:04 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> SK_MEMINFO_DROPS is added in linux-4.7 for TCP, UDP and SCTP
> 
> skmem will display the socket drop count using d prefix as in :
> 
> $ ss -tm src :22 | more
> State      Recv-Q Send-Q Local Address:Port    Peer Address:Port                
> ESTAB      0      52     10.246.7.151:ssh      172.20.10.101:50759                
> 	 skmem:(r0,rb8388608,t0,tb8388608,f1792,w2304,o0,bl0,d0)


Applied to net-next, thanks
