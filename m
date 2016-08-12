From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute v3 0/5] iproute: ila and fou additions
Date: Fri, 12 Aug 2016 12:55:20 -0700
Message-ID: <20160812125520.2fa612d1@xeon-e3>
References: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33162 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbcHLTzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 15:55:48 -0400
Received: by mail-pf0-f171.google.com with SMTP id y134so11870275pfg.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 12:55:09 -0700 (PDT)
In-Reply-To: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Aug 2016 14:41:34 -0700
Tom Herbert <tom@herbertland.com> wrote:

> Patch set includes:
> 
> - Allow configuring checksum mode for ila LWT (e.g. configure
>   checksum neutral
> - Configuration for performing ila translations using netfilter hook
> - fou encapsulation for ip6tnl and gre6
> - fou listener for IPv6
> 
> v2:
>   - Fixed coding style issues
> 
> v3:
>   - Fixed uniinitialized variable waning in ipila.c
> 
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
>  ip/ipfou.c            |   9 +-
>  ip/ipila.c            | 268 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  ip/iproute_lwtunnel.c |  58 ++++++++++-
>  ip/link_gre.c         |   2 +-
>  ip/link_gre6.c        | 101 +++++++++++++++++++
>  ip/link_ip6tnl.c      |  92 ++++++++++++++++-
>  9 files changed, 528 insertions(+), 8 deletions(-)
>  create mode 100644 ip/ipila.c
> 

Applied but I needed to fix one whitespace issue.
