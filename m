From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [Patch net] igmp: acquire pmc lock for ip_mc_clear_src()
Date: Tue, 13 Jun 2017 16:23:57 +0800
Message-ID: <CADvbK_csz4E5wAx7oGBhF6kU+DpmQvLgoGqGXyveMnxEMvD69Q@mail.gmail.com>
References: <1497286346-26888-1-git-send-email-xiyou.wangcong@gmail.com>
 <CADvbK_f=NePnrAvARnOMvg_o8G2bj-p1i1e_CXMZ6BooW3yhHA@mail.gmail.com> <CAM_iQpV7GmFfM2zo0ADxHm7fF4EErY5h3jLLKvNhfN+N-tYStQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:35110 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751753AbdFMIX7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 04:23:59 -0400
Received: by mail-qt0-f170.google.com with SMTP id w1so160311584qtg.2
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 01:23:58 -0700 (PDT)
In-Reply-To: <CAM_iQpV7GmFfM2zo0ADxHm7fF4EErY5h3jLLKvNhfN+N-tYStQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 13, 2017 at 2:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jun 12, 2017 at 11:30 AM, Xin Long <lucien.xin@gmail.com> wrote:
>> Hi, Cong.
>>
>> how about in ip_check_mc_rcu():
>>         for (psf = im->sources; psf; psf = psf->sf_next) {
>>                if (psf->sf_inaddr == src_addr)
>>                            break;
>>          }
>>
>> I didn't see spinlock for it, is it safe to access them in parallel ?
>> or these two places would never be in parallel ?
>
> That is a different bug which needs more work, therefore
> I defer it to net-next. And I already explained to you why
> it needs more work than just a call_rcu().
Okay, thanks Cong.

Reviewed-by: Xin Long <lucien.xin@gmail.com>
