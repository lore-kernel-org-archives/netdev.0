From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 41/54] smsc911x: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 13:41:55 -0700
Message-ID: <1395780115.12610.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-41-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:43184 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249AbaCYUl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:41:59 -0400
Received: by mail-pa0-f47.google.com with SMTP id lj1so959537pab.6
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:41:58 -0700 (PDT)
In-Reply-To: <1395727540-12148-41-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in smsc911x_hard_xmit
> which can be called in hard irq and other contexts. smsc911x_hard_xmit
> always transmits and consumes the specified skb.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Eric Dumazet <edumazet@google.com>
