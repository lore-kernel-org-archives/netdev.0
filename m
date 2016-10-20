From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: disable BH in set_ping_group_range()
Date: Thu, 20 Oct 2016 14:08:47 -0700
Message-ID: <1476997727.7065.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpVFQD0Oqf8YO9HybDpPMhzMMK5m_wNyLwTfVpEwpAVBNw@mail.gmail.com>
         <CAM_iQpVBHa2ujKN1hsU0LT+g899+WEy9a1oBgDj1FmpifPmz6g@mail.gmail.com>
         <CAM_iQpV-00gemayMkdLGzb8wo8CNimOZQHDXrvH1jeN6Svrs8w@mail.gmail.com>
         <1476996209.7065.28.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpX0=OnOfsGg_KGz=--_S+-1TG2=LoAmYVAOSxawCQtBUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Eric Salo <salo@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34492 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754474AbcJTVIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 17:08:49 -0400
Received: by mail-pf0-f194.google.com with SMTP id 128so6542003pfz.1
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 14:08:48 -0700 (PDT)
In-Reply-To: <CAM_iQpX0=OnOfsGg_KGz=--_S+-1TG2=LoAmYVAOSxawCQtBUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-20 at 14:00 -0700, Cong Wang wrote:

> Error prone vs. space saving, it's up to you...
> 
> But clearly current code is still broken even after your patch. I will send
> a revert + previous typo fix.

Yes please do.
