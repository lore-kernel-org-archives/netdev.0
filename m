From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute v3 2/5] ila: Support for configuring ila to use
 netfilter hook
Date: Fri, 12 Aug 2016 13:01:54 -0700
Message-ID: <20160812130154.35c7deda@xeon-e3>
References: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
	<1470778899-2854697-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:32916 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088AbcHLUBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 16:01:44 -0400
Received: by mail-pf0-f176.google.com with SMTP id y134so11909774pfg.0
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 13:01:44 -0700 (PDT)
In-Reply-To: <1470778899-2854697-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 9 Aug 2016 14:41:36 -0700
Tom Herbert <tom@herbertland.com> wrote:

> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  ip/Makefile    |   2 +-
>  ip/ip.c        |   3 +-
>  ip/ip_common.h |   1 +
>  ip/ipila.c     | 268 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 272 insertions(+), 2 deletions(-)
>  create mode 100644 ip/ipila.c

You didn't fix this warning.

ipila.c: In function ‘ila_parse_opt.constprop’:
ipila.c:205:2: warning: ‘locator_match’ may be used uninitialized in this function [-Wmaybe-uninitialized]
  addattr64(n, 1024, ILA_ATTR_LOCATOR_MATCH, locator_match);


Please send a followup patch for this.
