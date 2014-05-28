From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: various header include fixes for compiling
 with musl libc
Date: Wed, 28 May 2014 16:53:02 -0700
Message-ID: <20140528165302.078c6ff8@nehalam.linuxnetplumber.net>
References: <1401176410-16434-1-git-send-email-ncopa@alpinelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Natanael Copa <ncopa@alpinelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:54157 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964AbaE1XxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 19:53:05 -0400
Received: by mail-pb0-f42.google.com with SMTP id md12so12070444pbc.29
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 16:53:05 -0700 (PDT)
In-Reply-To: <1401176410-16434-1-git-send-email-ncopa@alpinelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 May 2014 07:40:10 +0000
Natanael Copa <ncopa@alpinelinux.org> wrote:

> We need limits.h for LONG_MIN and LONG_MAX, sys/param.h for MIN and
> sys/select for struct timeval.
> 
> This fixes the following compile errors with musl libc:
> 
> f_bpf.c: In function 'bpf_parse_opt':
> f_bpf.c:181:12: error: 'LONG_MIN' undeclared (first use in this function)
>    if (h == LONG_MIN || h == LONG_MAX) {
>             ^
> ...
> 
> tc_util.o: In function `print_tcstats2_attr':
> tc_util.c:(.text+0x13fe): undefined reference to `MIN'
> tc_util.c:(.text+0x1465): undefined reference to `MIN'
> tc_util.c:(.text+0x14ce): undefined reference to `MIN'
> tc_util.c:(.text+0x154c): undefined reference to `MIN'
> tc_util.c:(.text+0x160a): undefined reference to `MIN'
> tc_util.o:tc_util.c:(.text+0x174e): more undefined references to `MIN' follow
> ...
> 
> tc_stab.o: In function `print_size_table':
> tc_stab.c:(.text+0x40f): undefined reference to `MIN'
> ...
> 
> fdb.c:247:30: error: 'ULONG_MAX' undeclared (first use in this function)
>         (vni >> 24) || vni == ULONG_MAX)
>                               ^
> 
> lnstat.h:28:17: error: field 'last_read' has incomplete type
>   struct timeval last_read;  /* last time of read */
>                  ^
> 
> Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>

Applied
