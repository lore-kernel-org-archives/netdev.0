From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: reset timer after any SYNACK retransmit
Date: Mon, 29 Apr 2013 11:54:19 -0700
Message-ID: <1367261659.8964.332.camel@edumazet-glaptop>
References: <1367261091-28052-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	hagen@jauu.net, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:47417 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946Ab3D2SyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 14:54:23 -0400
Received: by mail-pa0-f48.google.com with SMTP id lb1so1910472pab.21
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 11:54:22 -0700 (PDT)
In-Reply-To: <1367261091-28052-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 11:44 -0700, Yuchung Cheng wrote:
> Linux immediately returns SYNACK on (spurious) SYN retransmits, but
> keeps the SYNACK timer running independently. Thus the timer may
> fire right after the SYNACK retransmit and causes a SYN-SYNACK
> cross-fire burst.
> 
> Adopt the fast retransmit/recovery idea in established state by
> re-arming the SYNACK timer after the fast (SYNACK) retransmit. The
> timer may fire late up to 500ms due to the current SYNACK timer wheel,
> but it's OK to be conservative when network is congested. Eric's new
> listener design should address this issue.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
