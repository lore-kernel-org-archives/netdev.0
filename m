From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 14/54] xgmac: Call dev_kfree/consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:16:25 -0700
Message-ID: <1395760585.12610.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-14-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:33084 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaCYPQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:16:44 -0400
Received: by mail-oa0-f51.google.com with SMTP id i4so753343oah.10
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:16:43 -0700 (PDT)
In-Reply-To: <1395727540-12148-14-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in xgmac_tx_complete
> that can be called in hard irq and other contexts.
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in xgmac_xmit that can
> be called in hard irq and other contexts.
> 
> dev_consume_skb_any is used in xgamc_tx_complete as skbs that reach
> there have been successfully transmitted, dev_kfree_skby_any is used
> in xgmac_xmit as skbs that are freed there are being dropped.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/calxeda/xgmac.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
