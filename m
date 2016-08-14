From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net v4 2/7] net_sched: remove an unnecessary list_del()
Date: Sun, 14 Aug 2016 07:01:46 -0400
Message-ID: <c3d6a5d4-900b-eb8c-baaf-216474c39209@mojatatu.com>
References: <1471152902-12444-1-git-send-email-xiyou.wangcong@gmail.com>
 <1471152902-12444-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33767 "EHLO
	mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964818AbcHNLBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2016 07:01:48 -0400
Received: by mail-qt0-f193.google.com with SMTP id j37so1163020qta.0
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2016 04:01:47 -0700 (PDT)
In-Reply-To: <1471152902-12444-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-14 01:34 AM, Cong Wang wrote:
> This list_del() for tc action is not needed actually,
> because we only use this list to chain bulk operations,
> therefore should not be carried for latter operations.
>
> Fixes: ec0595cc4495 ("net_sched: get rid of struct tcf_common")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
