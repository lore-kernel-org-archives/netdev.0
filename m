From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 29/54] jme: Call dev_kfree_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 08:45:29 -0700
Message-ID: <1395762329.12610.150.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-29-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f171.google.com ([209.85.128.171]:41926 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbaCYPpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 11:45:49 -0400
Received: by mail-ve0-f171.google.com with SMTP id cz12so756197veb.2
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 08:45:48 -0700 (PDT)
In-Reply-To: <1395727540-12148-29-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in jme_expand_header that
> can be called in hard irq and other contexts, on the failure
> path where the skb is dropped.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
