From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: crash in __kfree_skb on v3.18-rc5 with CONFIG_DEBUG_PAGEALLOC
Date: Fri, 21 Nov 2014 08:37:28 -0800
Message-ID: <1416587848.8629.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141121160937.GA32608@ret.masoncoding.com>
	 <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Mason <clm@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:53920 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755449AbaKUQho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 11:37:44 -0500
Received: by mail-ie0-f172.google.com with SMTP id ar1so5248156iec.17
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 08:37:43 -0800 (PST)
In-Reply-To: <1416587469.8629.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-11-21 at 08:31 -0800, Eric Dumazet wrote:

> Can you double check, or send whole __kfree_skb() disassembly ?
> 
> I do not understand how skb->fclone could possibly trap _at_ this point.

Oh well, I think commit ce1a4ea3f1258 ("net: avoid one atomic operation
in skb_clone()") is the problem, I'll send a revert.
