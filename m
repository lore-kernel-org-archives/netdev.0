From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] htb: support 64bit rates
Date: Fri, 22 Nov 2013 17:36:58 -0800
Message-ID: <20131122173658.5685d8aa@nehalam.linuxnetplumber.net>
References: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:59424 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755893Ab3KWBhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 20:37:02 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so2092141pbc.27
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 17:37:01 -0800 (PST)
In-Reply-To: <1384295647.28458.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Nov 2013 14:34:07 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Starting from linux-3.13, we can break the 32bit limitation of
> rates on HTB qdisc/classes.
> 
> Prior limit was 34.359.738.360 bits per second.
> 
> lpq83:~# tc -s qdisc show dev lo ; tc -s class show dev lo
> qdisc htb 1: root refcnt 2 r2q 2000 default 1 direct_packets_stat 0 direct_qlen 6000
>  Sent 6591936144493 bytes 149549182 pkt (dropped 0, overlimits 213757419 requeues 0) 
>  rate 39464Mbit 114938pps backlog 0b 15p requeues 0 
> class htb 1:1 root prio 0 rate 50000Mbit ceil 50000Mbit burst 200000b cburst 0b 
>  Sent 6591942184547 bytes 149549310 pkt (dropped 0, overlimits 0 requeues 0) 
>  rate 39464Mbit 114938pps backlog 0b 15p requeues 0 
>  lended: 149549310 borrowed: 0 giants: 0
>  tokens: 336 ctokens: -164
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied to net-next-for-3.13 branch
