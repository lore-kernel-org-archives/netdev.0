From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net] act_ipt: fix a bind refcnt leak
Date: Mon, 13 Jun 2016 17:56:51 -0400
Message-ID: <575F2C23.3010804@mojatatu.com>
References: <1465850654-27128-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34845 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbcFMV4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 17:56:53 -0400
Received: by mail-io0-f195.google.com with SMTP id n127so18433188iof.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:56:53 -0700 (PDT)
In-Reply-To: <1465850654-27128-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-13 04:44 PM, Cong Wang wrote:
> And avoid calling tcf_hash_check() twice.
>
> Fixes: a57f19d30b2d ("net sched: ipt action fix late binding")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Good catch.
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
