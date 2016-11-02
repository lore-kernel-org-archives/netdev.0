From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: Check for fullsock in sock_i_uid()
Date: Wed, 02 Nov 2016 10:18:27 -0700
Message-ID: <1478107107.7065.379.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478064420-11601-1-git-send-email-subashab@codeaurora.org>
         <1478075943.7065.361.camel@edumazet-glaptop3.roam.corp.google.com>
         <f77e1a0d37ef82933503018a974cc07a@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35827 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933405AbcKBRS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 13:18:29 -0400
Received: by mail-pf0-f193.google.com with SMTP id i88so2272010pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 10:18:29 -0700 (PDT)
In-Reply-To: <f77e1a0d37ef82933503018a974cc07a@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-02 at 11:05 -0600, subashab@codeaurora.org wrote:
> > This would be a bug in the caller.
> > 
> > Can you give us the complete stack trace leading to the problem you
> > had ?
> > 
> > Thanks !
> 
> Thanks Eric for the clarification. In that case, the bug is in the 
> IDLETIMER target in Android kernel.
> https://android.googlesource.com/kernel/common/+/android-4.4/net/netfilter/xt_IDLETIMER.c#356
> 
> Here is the call stack.

Sure, please fix Android, and not add ugly work around in linux kernel.

Lorenzo, have'nt you already fixed all these bugs ?

if (skb && skb->sk)
	timer->uid = from_kuid_munged(current_user_ns(),
				 sock_i_uid(skb_to_full_sk(skb)));

Thanks
