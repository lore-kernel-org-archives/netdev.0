From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 31/54] skge: Call dev_kfree/consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:47:33 -0700
Message-ID: <1395762453.12610.152.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-31-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:42451 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbaCYPrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:47:52 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so603672pdi.16
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:47:51 -0700 (PDT)
In-Reply-To: <1395727540-12148-31-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any skge_xmit_free that can
> be called in hard irq and other contexts, on the path that
> handles dropped packets.
> 
> Replace dev_kfree_skb with dev_consume_skb_any in skge_tx_done that can
> be called in hard irq and other contexts, on the path that handles
> successfully transmitted skbs.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
