From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next v2] ipv4: get rid of ip_ra_lock
Date: Fri, 28 Apr 2017 23:15:16 +0200
Message-ID: <869429ca-e88c-7bef-b8c0-61858d408023@stressinduktion.org>
References: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:33191 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1947180AbdD1VPT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 17:15:19 -0400
In-Reply-To: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.04.2017 19:04, Cong Wang wrote:
> After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
> we always take RTNL lock for ip_ra_control() which is the only place
> we update the list ip_ra_chain, so the ip_ra_lock is no longer needed.
> 
> As Eric points out, BH does not need to disable either, RCU readers
> don't care.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
