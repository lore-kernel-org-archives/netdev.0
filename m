From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] bnx2x: Fix configuration of doorbell block
Date: Mon, 09 Sep 2013 07:17:16 -0700
Message-ID: <1378736236.26319.29.camel@edumazet-glaptop>
References: <1378727487-6921-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:57705 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814Ab3IIORR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 10:17:17 -0400
Received: by mail-pb0-f51.google.com with SMTP id jt11so6145446pbb.38
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 07:17:17 -0700 (PDT)
In-Reply-To: <1378727487-6921-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-09 at 14:51 +0300, Ariel Elior wrote:
> As part of VF RSS feature doorbell block was configured not to use dpm, but
> a small part of configuration was left out, preventing the driver from sending
> tx messages to the device. This patch adds the missing configuration.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmil.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    1 +
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    3 ---
>  2 files changed, 1 insertions(+), 3 deletions(-)

Thanks for fixing this.

Tested-by: Eric Dumazet <edumazet@google.com>
