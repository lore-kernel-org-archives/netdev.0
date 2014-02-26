From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 -next] net: tcp: add mib counters to track zero
 window transitions
Date: Tue, 25 Feb 2014 21:07:22 -0800
Message-ID: <1393391242.2316.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393335272-12914-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:38912 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274AbaBZFHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 00:07:25 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so465404pab.1
        for <netdev@vger.kernel.org>; Tue, 25 Feb 2014 21:07:24 -0800 (PST)
In-Reply-To: <1393335272-12914-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-02-25 at 14:34 +0100, Florian Westphal wrote:
> Three counters are added:
> - one to track when we went from non-zero to zero window
> - one to track the reverse
> - one counter incremented when we want to announce zero window,
>   but can't because we would shrink current window.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
> Changes in v2:
>  - use NET_INC_STATS, not _BH; can be called from both bh and process context (pointed out by Hannes)
>  - rename LINUX_MIB_TCPWANTZEROWINDOW to LINUX_MIB_TCPWANTZEROWINDOWADV for consistency

Thanks Florian

Acked-by: Eric Dumazet <edumazet@google.com>
