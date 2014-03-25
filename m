From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 46/54] via-rhine: Call dev_kfree/consume_skb_any instead
 of dev_kfree_skb.
Date: Tue, 25 Mar 2014 13:44:54 -0700
Message-ID: <1395780294.12610.176.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-46-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:50249 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbaCYUo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:44:56 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so941070pdj.22
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:44:56 -0700 (PDT)
In-Reply-To: <1395727540-12148-46-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in rhine_start_tx which
> can be called in hard irq and other contexts.  Packets are only freed
> in rhine_start_tx if they are dropped.
> 
> Replace dev_kfree_skb with dev_consume_skb_any in rhine_tx that can be
> called in hard irq and other contexts.  rhine_tx handles successfully
> transmitted packets.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Eric Dumazet <edumazet@google.com>
