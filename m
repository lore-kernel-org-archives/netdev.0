From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/ipv4/netfilter/ip_tables.c: remove some inlines
Date: Mon, 17 Dec 2007 15:47:05 +0100
Message-ID: <47668BE9.8010504@trash.net>
References: <200712161247.53986.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200712161247.53986.vda.linux@googlemail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please CC netfilter-devel on netfilter patches.

Denys Vlasenko wrote:
> Hi Patrick, Harald,
> 
> I was working on unrelated problem and noticed that ip_tables.c
> seem to abuse inline. I prepared a patch which removes inlines
> except those which are used by packet matching code
> (and thus are really performance-critical).
> I added comments explaining that remaining inlines are
> performance critical.
> 
> Result as reported by size:
> 
>    text    data     bss     dec     hex filename
> -  6451     380      88    6919    1b07 ip_tables.o
> +  6339     348      72    6759    1a67 ip_tables.o
> 
> Please take this patch into netfilter queue.


This clashes with my pending patches, which I'll push upstream
today. I also spent some time resyncing ip_tables and ip6_tables
so a diff of both (with some sed'ing) shows only the actual
differences, so please update ip6_tables as well.

