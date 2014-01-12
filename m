From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 4/7] net_sched: optimize tcf_match_indev()
Date: Sun, 12 Jan 2014 07:50:01 -0500
Message-ID: <52D28F79.2040600@mojatatu.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com> <1389312845-10304-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:35120 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbaALMuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 07:50:05 -0500
Received: by mail-ig0-f172.google.com with SMTP id k19so1383446igc.5
        for <netdev@vger.kernel.org>; Sun, 12 Jan 2014 04:50:04 -0800 (PST)
In-Reply-To: <1389312845-10304-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/14 19:14, Cong Wang wrote:
> tcf_match_indev() is called in fast path, it is not wise to
> search for a netdev by ifindex and then compare by its name,
> just compare the ifindex.
>
> Also, dev->name could be changed by user-space, therefore
> the match would be always fail, but dev->ifindex could
> be consistent.
>
> BTW, this will also save some bytes from the core struct of u32.
>

excellent.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
