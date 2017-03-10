From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Fri, 10 Mar 2017 00:34:54 -0700
Message-ID: <d48f786ea0deaafabff53c90da19a2fb@codeaurora.org>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <1489119936.28631.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:54218 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdCJHe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:34:56 -0500
In-Reply-To: <1489119936.28631.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, then you need to make sure ipprot->early_demux is read once in 
> the
> callers, like ip_rcv_finish(), otherwise compiler could read it twice
> and we could deref a NULL pointer.
> 
> ipprot = rcu_dereference(inet_protos[protocol]);
> if (ipprot && ipprot->early_demux) {
>     ipprot->early_demux(skb);   // crash

Thanks Eric. I'll update this.
