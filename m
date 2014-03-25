From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 33/54] ksz884x: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 09:23:37 -0700
Message-ID: <1395764617.12610.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-33-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:37490 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbaCYQXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 12:23:39 -0400
Received: by mail-pa0-f44.google.com with SMTP id bj1so666304pad.17
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 09:23:39 -0700 (PDT)
In-Reply-To: <1395727540-12148-33-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in copy_old_skb that can
> be called in hard irq and other contexts.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/micrel/ksz884x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
