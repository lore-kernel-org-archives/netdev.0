From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2 support for Heavy Hitter Filter (HHF) qdisc.
Date: Thu, 9 Jan 2014 22:55:19 -0800
Message-ID: <20140109225519.1a33604a@nehalam.linuxnetplumber.net>
References: <1389255791-16964-1-git-send-email-vtlam@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nandita Dukkipati <nanditad@google.com>
To: Terry Lam <vtlam@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:51466 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaAJHMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 02:12:06 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so4213892pde.28
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 23:12:05 -0800 (PST)
In-Reply-To: <1389255791-16964-1-git-send-email-vtlam@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Jan 2014 00:23:11 -0800
Terry Lam <vtlam@google.com> wrote:

> $tc qdisc add dev eth0 hhf help
> Usage: ... hhf [ limit PACKETS ] [ quantum BYTES]
>                [ hh_limit NUMBER ]
>                [ reset_timeout TIME ]
>                [ admit_bytes BYTES ]
>                [ evict_timeout TIME ]
>                [ non_hh_weight NUMBER ]
> 
> $tc -s -d qdisc show dev eth0
> qdisc hhf 8005: root refcnt 32 limit 1000p quantum 1514 hh_limit 2048
> reset_timeout 40.0ms admit_bytes 131072 evict_timeout 1.0s non_hh_weight 2
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>   backlog 0b 0p requeues 0
>     drop_overlimit 0 hh_overlimit 0 tot_hh 0 cur_hh 0
> 
> HHF qdisc parameters:
> - limit: max number of packets in qdisc (default 1000)
> - quantum: max deficit per RR round (default 1 MTU)
> - hh_limit: max number of HHs to keep states (default 2048)
> - reset_timeout: time to reset HHF counters (default 40ms)
> - admit_bytes: counter thresh to classify as HH (default 128KB)
> - evict_timeout: threshold to evict idle HHs (default 1s)
> - non_hh_weight:  DRR weight for mice (default 2)
> 
> Signed-

Applied to net-next-for-3.13 branch
