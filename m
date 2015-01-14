From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/3] ip netns: Run over all netns
Date: Tue, 13 Jan 2015 17:28:37 -0800
Message-ID: <20150113172837.793f0969@urahara>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55164 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335AbbANB2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 20:28:46 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so7078837pab.7
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 17:28:46 -0800 (PST)
In-Reply-To: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Jan 2015 13:04:19 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Allow 'ip netns del' and 'ip netns exec' run over each network namespace names.
> 
> 'ip netns exec' executes command forcely on eacn nsname.
> 
> Vadim Kochan (3):
>   lib: Exec func on each netns
>   ip netns: Allow exec on each netns
>   ip netns: Delete all netns
> 
>  include/namespace.h |  6 ++++
>  include/utils.h     |  5 +++
>  ip/ipnetns.c        | 96 ++++++++++++++++++++++++++++++++---------------------
>  lib/namespace.c     | 22 ++++++++++++
>  lib/utils.c         | 28 ++++++++++++++++
>  man/man8/ip-netns.8 | 26 ++++++++++++---
>  6 files changed, 141 insertions(+), 42 deletions(-)
> 

It is a useful concept but as others have pointed out the idea of reserving
a keyword 'all' at this point is likely to cause somebody to break.
So sorry.
