From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute 0/5] iproute: ila and fou additions
Date: Fri, 15 Jul 2016 11:23:26 -0700
Message-ID: <20160715112326.1520599e@xeon-e3>
References: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<shemming@brocade.com>, <kernel-team@fb.com>, <haoxuany@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36490 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbcGOSXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:23:10 -0400
Received: by mail-pa0-f44.google.com with SMTP id pp5so34774661pac.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:23:10 -0700 (PDT)
In-Reply-To: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Jul 2016 12:22:11 -0700
Tom Herbert <tom@herbertland.com> wrote:

> Patch set includes:
> 
> - Allow configuring checksum mode for ila LWT (e.g. configure
>   checksum neutral
> - Configuration for performing ila translations using netfilter hook
> - fou encapsulation for ip6tnl and gre6
> - fou listener for IPv6
> 
> *** SUBJECT HERE ***
> 
> *** BLURB HERE ***
> 
> Tom Herbert (5):
>   ila: Support for checksum neutral translation
>   ila: Support for configuring ila to use netfilter hook
>   ip6tnl: Support for fou encapsulation
>   gre6: Support for fou encapsulation
>   fou: Allowing configuring IPv6 listener
> 
>  ip/Makefile           |   2 +-
>  ip/ip.c               |   3 +-
>  ip/ip_common.h        |   1 +
>  ip/ipfou.c            |   8 +-
>  ip/ipila.c            | 259 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  ip/iproute_lwtunnel.c |  57 ++++++++++-
>  ip/link_gre6.c        | 101 ++++++++++++++++++++
>  ip/link_ip6tnl.c      |  92 +++++++++++++++++-
>  8 files changed, 516 insertions(+), 7 deletions(-)
>  create mode 100644 ip/ipila.c
> 

I am okay with the content of these patches, but they have have lots of style issues.

1. Bad indentation in several spots
2. Lines are too long
3. Use rta_getattr_u64, look for places that access RTA_DATA() directly
5. Run checkpatch
