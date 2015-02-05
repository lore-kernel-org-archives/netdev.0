From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 0/3] ip netns: Run over all netns
Date: Thu, 5 Feb 2015 10:29:16 -0800
Message-ID: <20150205102916.1b99849e@urahara>
References: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:56023 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbbBES3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:29:17 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so6901359pad.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:29:17 -0800 (PST)
In-Reply-To: <1421590219-19365-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Jan 2015 16:10:16 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.
> 
> 'ip netns exec' executes command forcely on eacn nsname.
> 
> Added new '-all' 'ip' option to run over each netns,
> it can be used for other utils as generic option.
> 
> v2:
>    Use '-all' option instead of netns name 'all'.
> 
> Vadim Kochan (3):
>   lib: Exec func on each netns
>   ip netns: Allow exec on each netns
>   ip netns: Delete all netns
> 
>  include/namespace.h |  6 ++++
>  include/utils.h     |  5 +++
>  ip/ip.c             |  5 ++-
>  ip/ipnetns.c        | 98 ++++++++++++++++++++++++++++++++---------------------
>  lib/namespace.c     | 22 ++++++++++++
>  lib/utils.c         | 28 +++++++++++++++
>  man/man8/ip-netns.8 | 28 ++++++++++++---
>  man/man8/ip.8       |  7 +++-
>  8 files changed, 153 insertions(+), 46 deletions(-)
> 

Accepted
