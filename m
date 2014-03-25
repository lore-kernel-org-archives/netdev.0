From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 20/54] dm9000: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:26:15 -0700
Message-ID: <1395761175.12610.139.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-20-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:58290 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbaCYP0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:26:21 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so578439pdj.20
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:26:21 -0700 (PDT)
In-Reply-To: <1395727540-12148-20-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in dm9000_start_xmit
> that can be called in hard irq and other contexts, on the path
> that successfully transmits the packet.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/davicom/dm9000.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
