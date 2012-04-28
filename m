From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] drop_monitor: Make updating data->skb smp safe
Date: Sat, 28 Apr 2012 08:13:35 +0200
Message-ID: <1335593615.2900.1.camel@edumazet-glaptop>
References: <1335466022-32661-1-git-send-email-nhorman@tuxdriver.com>
	 <1335557509-32726-1-git-send-email-nhorman@tuxdriver.com>
	 <1335557509-32726-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:59932 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab2D1GNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 02:13:39 -0400
Received: by wgbds11 with SMTP id ds11so1060421wgb.1
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 23:13:38 -0700 (PDT)
In-Reply-To: <1335557509-32726-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 16:11 -0400, Neil Horman wrote:
> Eric Dumazet pointed out to me that the drop_monitor protocol has some holes in
> its smp protections.  Specifically, its possible to replace data->skb while its
> being written.  This patch corrects that by making data->skb and rcu protected
> variable.  That will prevent it from being overwritten while a tracepoint is
> modifying it.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: David Miller <davem@davemloft.net>
> ---
>  net/core/drop_monitor.c |   70 ++++++++++++++++++++++++++++++++++++-----------
>  1 files changed, 54 insertions(+), 16 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Neil
