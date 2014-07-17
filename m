From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: cancel nest attribute on failure
 in tcf_exts_dump()
Date: Thu, 17 Jul 2014 08:39:34 -0400
Message-ID: <53C7C406.3020000@mojatatu.com>
References: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:42420 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbaGQMjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 08:39:44 -0400
Received: by mail-ie0-f179.google.com with SMTP id rl12so2795271iec.10
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 05:39:43 -0700 (PDT)
In-Reply-To: <1405545931-13832-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/14 17:25, Cong Wang wrote:
> From: Cong Wang <cwang@twopensource.com>
>
> Like other places, we need to cancel the nest attribute after
> we start. Fortunately the netlink message will not be sent on
> failure, so it's not a big problem at all.
>

Sure.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
