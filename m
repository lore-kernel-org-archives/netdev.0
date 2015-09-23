From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] net: revert "net_sched: move tp->root allocation into
 fw_init()"
Date: Wed, 23 Sep 2015 14:43:28 -0400
Message-ID: <5602F2D0.1050608@mojatatu.com>
References: <1442966471-22656-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Akshat Kakkar <akshat.1984@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33105 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbbIWSnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 14:43:35 -0400
Received: by iofh134 with SMTP id h134so52455263iof.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 11:43:35 -0700 (PDT)
In-Reply-To: <1442966471-22656-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/15 20:01, Cong Wang wrote:
> fw filter uses tp->root==NULL to check if it is the old method,
> so it doesn't need allocation at all in this case. This patch
> reverts the offending commit and adds some comments for old
> method to make it obvious.
>
> Fixes: 33f8b9ecdb15 ("net_sched: move tp->root allocation into fw_init()")
> Reported-by: Akshat Kakkar <akshat.1984@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
