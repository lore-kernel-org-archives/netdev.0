From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] enic: support skb->xmit_more
Date: Wed, 19 Nov 2014 07:33:56 -0800
Message-ID: <1416411236.14060.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416382172-28775-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57484 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351AbaKSPd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 10:33:58 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so1076534pdb.0
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 07:33:58 -0800 (PST)
In-Reply-To: <1416382172-28775-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-19 at 12:59 +0530, Govindarajulu Varadarajan wrote:
> Check and update posted_index only when skb->xmit_more is 0 or tx queue is full.
> 
> v2:
> use txq_map instead of skb_get_queue_mapping(skb)
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c |  8 ++++++--
>  drivers/net/ethernet/cisco/enic/vnic_wq.h   | 20 +++++++++++---------
>  2 files changed, 17 insertions(+), 11 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
