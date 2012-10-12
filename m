From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Ip6{In,Out}BcastPkts statistics missing from
 /proc/net/snmp6
Date: Fri, 12 Oct 2012 08:30:02 +0200
Message-ID: <1350023402.21172.10776.camel@edumazet-glaptop>
References: <S1754091Ab2JLF5l/20121012055741Z+350@vger.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Niels Baggesen <nba@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:55396 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754531Ab2JLGaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 02:30:06 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so1612662eek.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 23:30:04 -0700 (PDT)
In-Reply-To: <S1754091Ab2JLF5l/20121012055741Z+350@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-12 at 01:57 -0400, Niels Baggesen wrote:
> The subject line says it all:
> 
> Ip6{In,Out}BcastPkts statistics missing from /proc/net/snmp6
> 
> Signed-off-by: Niels Baggesen <nba@users.sourceforge.net>
> 
> 
> --- net/ipv6/proc.c.orig    2012-10-01 12:52:09.452543199 +0200
> +++ net/ipv6/proc.c    2012-10-01 12:53:19.794660628 +0200
> @@ -90,6 +90,8 @@
>       SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
>       SNMP_MIB_ITEM("Ip6InBcastOctets", IPSTATS_MIB_INBCASTOCTETS),
>       SNMP_MIB_ITEM("Ip6OutBcastOctets", IPSTATS_MIB_OUTBCASTOCTETS),
> +     SNMP_MIB_ITEM("Ip6InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
> +     SNMP_MIB_ITEM("Ip6OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
>       SNMP_MIB_SENTINEL
>   };
> 
> /Niels
> 

And does it give useful information ?

As far as I know, IPv6 doesnt increment these counters, but I might be
wrong.
