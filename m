From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] dccp: fix use-after-free in
 dccp_feat_activate_values
Date: Sun, 05 Mar 2017 22:42:09 -0800
Message-ID: <1488782529.9415.371.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAeHK+xDhUDe9_-uEakJG9iqTtD_+fFr+JyUbkWCHHLBCcu1uQ@mail.gmail.com>
         <CAM_iQpUVusW6YJqSgXSo2hAA2dCZGYxw4h+A1_iBpaiYMsXDMA@mail.gmail.com>
         <CACT4Y+YUJGsvzFuFT3r0M-3KbPrcx62fzSHHQX=B43-syLYU0A@mail.gmail.com>
         <1488551576.9415.328.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488552503.9415.330.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+Z6t_jGoh3Gm3Sxuu_ugF5kQ3QJ37LVdqoEK_ab52tQMA@mail.gmail.com>
         <CACT4Y+ZhNzcKTODGkD3R-68KgkOtYCaf4cZYPH51=HhREXVPGg@mail.gmail.com>
         <CANn89i+E+DkUJBV-3AQ38hstj9=G7=3fLJuG8LA6upp77ecwPA@mail.gmail.com>
         <1488556814.9415.334.camel@edumazet-glaptop3.roam.corp.google.com>
         <CACT4Y+Zg9PptopGHPBYmf_2hfHg3kTrTkyhQuT9C7Krf4nX6AA@mail.gmail.com>
         <1488739936.9415.368.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpUwGN_M8SVWVprUk04fduOb_Fd7kXWhoJWMi5dUQ6RPcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36583 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752701AbdCFGmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 01:42:13 -0500
Received: by mail-pg0-f49.google.com with SMTP id 187so9036202pgb.3
        for <netdev@vger.kernel.org>; Sun, 05 Mar 2017 22:42:12 -0800 (PST)
In-Reply-To: <CAM_iQpUwGN_M8SVWVprUk04fduOb_Fd7kXWhoJWMi5dUQ6RPcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-03-05 at 21:38 -0800, Cong Wang wrote:

> Do you really want to disable BH again here?
> 
> dccp_check_req() should be always called on RX path where BH
> is already disabled and BH can't be disabled twice?

What makes you think BH can't be disabled twice ?

Look, I prefer being cautious here, no need to get another DCCP bug
report later.
