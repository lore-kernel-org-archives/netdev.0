From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 51/54] wlags49_h2: Call dev_kfree/consume_skb_any
 instead of dev_kfree_skb.
Date: Tue, 25 Mar 2014 13:47:20 -0700
Message-ID: <1395780440.12610.181.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-51-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:51424 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbaCYUrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:47:21 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so943340pdj.34
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:47:21 -0700 (PDT)
In-Reply-To: <1395727540-12148-51-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in wl_send and
> wl_send_dma which can be called in hard irq and other contexts,
> on the code paths where the skb was transmitted successfully.
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in wl_send_dmay which can
> be called in hard irq and other contexts, on the code path where a
> skb is dropped.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
