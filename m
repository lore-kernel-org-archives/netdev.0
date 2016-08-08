From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: remove an unnecessary list_del()
Date: Mon, 8 Aug 2016 10:01:55 -0700
Message-ID: <CAM_iQpXGz86=c-40AZk_PTT8urHNK8T2_OgVEcMSVLA1QgfacQ@mail.gmail.com>
References: <1470159046-23577-1-git-send-email-xiyou.wangcong@gmail.com> <1470159046-23577-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:36061 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbcHHRCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 13:02:17 -0400
Received: by mail-it0-f51.google.com with SMTP id x130so79137735ite.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 10:02:16 -0700 (PDT)
In-Reply-To: <1470159046-23577-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 2, 2016 at 10:30 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> This list_del() for tc action is not needed actually,
> because we only use this list to chain bulk operations,
> therefore should not be carried for latter operations.
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

David, please drop this patch from your backlog, I will
resend it with Fixes tag.
