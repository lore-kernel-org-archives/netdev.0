From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tg3: Add skb->xmit_more support
Date: Mon, 13 Oct 2014 09:48:54 -0700
Message-ID: <1413218934.9362.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413217302-15396-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dborkman@redhat.com,
	mchan@broadcom.com
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:38851 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbaJMQtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 12:49:01 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so6060071pad.25
        for <netdev@vger.kernel.org>; Mon, 13 Oct 2014 09:49:00 -0700 (PDT)
In-Reply-To: <1413217302-15396-1-git-send-email-prashant@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-13 at 09:21 -0700, Prashant Sreedharan wrote:
> Ring TX doorbell only if xmit_more is not set or the queue is stopped.
> 
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c |   10 ++++++----
>  1 files changed, 6 insertions(+), 4 deletions(-)

Have you noticed any performance change ?

I did the patch for bnx2x but got no real difference...

Thanks
