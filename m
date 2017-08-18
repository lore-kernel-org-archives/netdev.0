From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ipv4: convert dst_metrics.refcnt from
 atomic_t to refcount_t
Date: Fri, 18 Aug 2017 11:01:49 -0700
Message-ID: <1503079309.22502.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502911469.4936.148.camel@edumazet-glaptop3.roam.corp.google.com>
         <1502925599.4936.153.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAM_iQpWbxs6aa-axQrwN5pipaCDX3ws_08LaQON8p4WfrJ7SDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33274 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750913AbdHRSBw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 14:01:52 -0400
Received: by mail-pg0-f50.google.com with SMTP id t3so40793901pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 11:01:51 -0700 (PDT)
In-Reply-To: <CAM_iQpWbxs6aa-axQrwN5pipaCDX3ws_08LaQON8p4WfrJ7SDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-18 at 10:15 -0700, Cong Wang wrote:

> #include linux/refcount.h explicitly?

Sure, I will send a v3, thanks.
