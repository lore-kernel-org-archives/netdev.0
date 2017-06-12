From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] igmp: acquire pmc lock for ip_mc_clear_src()
Date: Mon, 12 Jun 2017 11:35:45 -0700
Message-ID: <CAM_iQpV7GmFfM2zo0ADxHm7fF4EErY5h3jLLKvNhfN+N-tYStQ@mail.gmail.com>
References: <1497286346-26888-1-git-send-email-xiyou.wangcong@gmail.com> <CADvbK_f=NePnrAvARnOMvg_o8G2bj-p1i1e_CXMZ6BooW3yhHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:33808 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751594AbdFLSgH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 14:36:07 -0400
Received: by mail-wr0-f173.google.com with SMTP id g76so105909606wrd.1
        for <netdev@vger.kernel.org>; Mon, 12 Jun 2017 11:36:07 -0700 (PDT)
In-Reply-To: <CADvbK_f=NePnrAvARnOMvg_o8G2bj-p1i1e_CXMZ6BooW3yhHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 12, 2017 at 11:30 AM, Xin Long <lucien.xin@gmail.com> wrote:
> Hi, Cong.
>
> how about in ip_check_mc_rcu():
>         for (psf = im->sources; psf; psf = psf->sf_next) {
>                if (psf->sf_inaddr == src_addr)
>                            break;
>          }
>
> I didn't see spinlock for it, is it safe to access them in parallel ?
> or these two places would never be in parallel ?

That is a different bug which needs more work, therefore
I defer it to net-next. And I already explained to you why
it needs more work than just a call_rcu().
