From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net: sched: set xt_tgchk_param par.nft_compat with
 false in ipt_init_target
Date: Tue, 8 Aug 2017 14:17:44 +1200
Message-ID: <CADvbK_dLkTtdQF_fN4CW09g__PF01Etpuw0G2YEMSv4xcLiw0A@mail.gmail.com>
References: <985e6cb7c94f0014096ebca47e1efd74e022dc8d.1501932779.git.lucien.xin@gmail.com>
 <CAM_iQpUT8CMdz1sgBaVS+7drzPPFp10APOHiKPib8oNq7kPsFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:38866 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751639AbdHHCRp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 22:17:45 -0400
Received: by mail-qt0-f194.google.com with SMTP id p3so2150054qtg.5
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 19:17:44 -0700 (PDT)
In-Reply-To: <CAM_iQpUT8CMdz1sgBaVS+7drzPPFp10APOHiKPib8oNq7kPsFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 9:03 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, Aug 5, 2017 at 4:32 AM, Xin Long <lucien.xin@gmail.com> wrote:
>> Commit 55917a21d0cc ("netfilter: x_tables: add context to know if
>> extension runs from nft_compat") introduced a member nft_compat to
>> xt_tgchk_param structure.
>>
>> But it didn't set it's value for ipt_init_target. With unexpected
>> value in par.nft_compat, it may return unexpected result in some
>> target's checkentry.
>>
>> This patch is to set par.nft_compat with false in ipt_init_target.
>
> It's time to set all these fields to 0 and only initialize those non-zero
> fields, in case we will add more fields in the future.
ok, the new fix is depend on the net_id one.
I will post v2 after that one gets accepted. thanks.
