From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 45/54] spider_net: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 13:44:31 -0700
Message-ID: <1395780271.12610.175.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-45-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:63282 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbaCYUod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:44:33 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so931073pdj.8
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:44:33 -0700 (PDT)
In-Reply-To: <1395727540-12148-45-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in
> spider_net_release_tx_chain which can be called in hard irq and other
> contexts.
> 
> dev_consume_skb_any was choosen as it preserves the current
> dev_kfree_skb semantics (dev_kfree_skb is consume_skb) and
> is because it is correct most of the time as most packets
> will have been successfully transmitted not dropeed.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
