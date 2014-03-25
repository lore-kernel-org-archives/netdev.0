From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 23/54] sundance: Call dev_kfree_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:29:35 -0700
Message-ID: <1395761375.12610.142.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-23-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:57440 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbaCYP3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:29:38 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so748545obc.1
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:29:38 -0700 (PDT)
In-Reply-To: <1395727540-12148-23-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in start_tx that can
> be called in hard irq and other contexts, when the skb is dropped.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/dlink/sundance.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
