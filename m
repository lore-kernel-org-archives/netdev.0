From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 50/54] xen-netfront: Call dev_kfree_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 13:46:36 -0700
Message-ID: <1395780396.12610.180.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-50-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:65167 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065AbaCYUqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:46:37 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so971902pad.7
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:46:37 -0700 (PDT)
In-Reply-To: <1395727540-12148-50-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in xennet_start_xmit
> which can be called in hard irq and other contexts.  xennet_start_xmit
> only fress skbs which it drops.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
