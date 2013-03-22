From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: increase inner ip id during
 encapsulated tso
Date: Thu, 21 Mar 2013 21:34:34 -0700
Message-ID: <1363926874.4431.57.camel@edumazet-glaptop>
References: <1363916305-15690-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>,
	Maciej Zenczykowski <maze@google.com>,
	Jesse Gross <jesse@nicira.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:39898 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab3CVEei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 00:34:38 -0400
Received: by mail-pb0-f41.google.com with SMTP id um15so2788895pbc.14
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 21:34:37 -0700 (PDT)
In-Reply-To: <1363916305-15690-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 03:38 +0200, Dmitry Kravkov wrote:
> 57712/578xx devices during handling of encapsulated TSO can
> properly increase ip id for only one ip header.
> The patch selects inner header to be increased.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> CC: Ariel Elior <ariele@broadcom.com>
> CC: Maciej Zenczykowski <maze@google.com>
> CC: Jesse Gross <jesse@nicira.com>
> ---
> tested over 1bc277f79
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |   22 ++++++++++------------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    1 +
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c   |    2 ++
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h   |    3 ++-
>  4 files changed, 15 insertions(+), 13 deletions(-)

Fine, GRO is back 

Reported-by: Eric Dumazet <edumazet@google.com>
Tested-by: Eric Dumazet <edumazet@google.com>

Thanks !
