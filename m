From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 54/54] if_vlan: Call dev_kfree_skb_any instead of
 kfree_skb.
Date: Tue, 25 Mar 2014 13:48:48 -0700
Message-ID: <1395780528.12610.184.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-54-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55314 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754943AbaCYUsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 16:48:50 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so976227pbb.19
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 13:48:49 -0700 (PDT)
In-Reply-To: <1395727540-12148-54-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:05 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace kfree_skb with dev_kfree_skb_any in vlan_insert_tag as
> vlan_insert_tag can be called from hard irq context (netpoll)
> and from other contexts.
> 
> dev_kfree_skb_any is used as vlan_insert_tag only frees the skb if the
> skb can not be modified to insert a tag, in which case vlan_insert_tag
> drops the skb.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Acked-by: Eric Dumazet <edumazet@google.com>
