From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/54] lance: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:14:37 -0700
Message-ID: <1395753277.12610.116.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-8-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:50755 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbaCYNOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:14:39 -0400
Received: by mail-pb0-f45.google.com with SMTP id uo5so435610pbc.18
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:14:39 -0700 (PDT)
In-Reply-To: <1395727540-12148-8-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in lance_start_xmit
> that can be called in hard irq and other contexts.
> 
> dev_consume_skb_any is used as lance_start_xmit always immediately
> consumes the skb.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
