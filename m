From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] tcp: allow to turn tcp timestamp
 randomization off
Date: Tue, 29 Nov 2016 10:07:12 -0800
Message-ID: <1480442832.18162.148.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480434342-12367-1-git-send-email-fw@strlen.de>
         <1480434342-12367-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36560 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756093AbcK2SHO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:07:14 -0500
Received: by mail-pf0-f196.google.com with SMTP id c4so8732624pfb.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:07:13 -0800 (PST)
In-Reply-To: <1480434342-12367-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-29 at 16:45 +0100, Florian Westphal wrote:
> Eric says: "By looking at tcpdump, and TS val of xmit packets of multiple
> flows, we can deduct the relative qdisc delays (think of fq pacing).
> This should work even if we have one flow per remote peer."
> 
> Having random per flow (or host) offsets doesn't allow that anymore so add
> a way to turn this off.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Excellent, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
