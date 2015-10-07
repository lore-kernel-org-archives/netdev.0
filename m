From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] act_mirred: clear sender cpu before sending to tx
Date: Tue, 06 Oct 2015 18:27:25 -0700
Message-ID: <1444181245.9555.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444177427-5603-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34888 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157AbbJGB11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 21:27:27 -0400
Received: by pacfv12 with SMTP id fv12so3762349pac.2
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 18:27:27 -0700 (PDT)
In-Reply-To: <1444177427-5603-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-10-06 at 17:23 -0700, Cong Wang wrote:
> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before forwarding")
> the skb->sender_cpu needs to be cleared when moving from Rx
> Tx, otherwise kernel could crash.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
Acked-by: Eric Dumazet <edumazet@google.com>
