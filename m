From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next v2 1/2] net_sched: prepare tcf_hashinfo_destroy()
 for netns support
Date: Tue, 23 Feb 2016 08:01:36 -0500
Message-ID: <56CC5830.6040308@mojatatu.com>
References: <1456185473-25403-1-git-send-email-xiyou.wangcong@gmail.com>
 <1456185473-25403-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34496 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbcBWNBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 08:01:38 -0500
Received: by mail-ig0-f179.google.com with SMTP id g6so110583156igt.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 05:01:38 -0800 (PST)
In-Reply-To: <1456185473-25403-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-22 06:57 PM, Cong Wang wrote:
> We only release the memory of the hashtable itself, not its
> entries inside. This is not a problem yet since we only call
> it in module release path, and module is refcount'ed by
> actions. This would be a problem after we move the per module
> hinfo into per netns in the latter patch.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
