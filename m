From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] fq_codel: add per queue memory limit
Date: Wed, 8 Jun 2016 08:33:20 -0700
Message-ID: <20160608083320.7d950b9a@xeon-e3>
References: <1464791011.5939.150.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36145 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbcFHPdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 11:33:07 -0400
Received: by mail-pa0-f45.google.com with SMTP id b5so3477559pas.3
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 08:33:06 -0700 (PDT)
In-Reply-To: <1464791011.5939.150.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Jun 2016 07:23:31 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> This patch adds support for TCA_FQ_CODEL_MEMORY_LIMIT attribute.
> 
> # tc qd replace dev eth1 root est 1sec 4sec fq_codel memory_limit 4M
> ..
> # tc -s -d qd sh dev eth1
> qdisc fq_codel 8008: root refcnt 257 limit 10240p flows 1024
>  quantum 1514 target 5.0ms interval 100.0ms memory_limit 4Mb ecn
>  Sent 2083566791363 bytes 1376214889 pkt (dropped 4994406, overlimits 0
> requeues 21705223)
>  rate 9841Mbit 812549pps backlog 3906120b 376p requeues 21705223
>   maxpacket 68130 drop_overlimit 4994406 new_flow_count 28855414
>   ecn_mark 0 memory_used 4190048 drop_overmemory 4994406
> new_flows_len 1 old_flows_len 177
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied but I had to fix a couple of conflicts because recent checkpatch cleanup
of tc files.
