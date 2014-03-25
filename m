From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 04/54] 8390: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:06:17 -0700
Message-ID: <1395752777.12610.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-4-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:37828 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaCYNGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:06:20 -0400
Received: by mail-oa0-f41.google.com with SMTP id j17so503618oag.14
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:06:19 -0700 (PDT)
In-Reply-To: <1395727540-12148-4-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in __ei_start_xmit that
> can be called in hard irq and other contexts.
> 
> dev_consume_skb is used as in this simple driver the skb is always
> immediately consumed, there are no drops.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
