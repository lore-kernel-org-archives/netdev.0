From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 18/54] cs89x0: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:23:39 -0700
Message-ID: <1395761019.12610.137.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-18-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:46866 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753583AbaCYPXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:23:47 -0400
Received: by mail-pb0-f48.google.com with SMTP id md12so597642pbc.21
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:23:46 -0700 (PDT)
In-Reply-To: <1395727540-12148-18-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in net_send_packet that
> can be called in hard irq and other contexts.
> 
> net_send_packet consumes (not drops) the skb of interest.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
Acked-by: Eric Dumazet <edumazet@google.com>
