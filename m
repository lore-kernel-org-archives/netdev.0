From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Thu, 13 Apr 2017 13:16:43 -0700
Message-ID: <CACKFLikm1vDzz8eQJMJOEsbv-NNV41ki2TEPVPCSpP6VjaowBA@mail.gmail.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36413 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755261AbdDMUQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 16:16:45 -0400
Received: by mail-lf0-f51.google.com with SMTP id s141so34757869lfe.3
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 13:16:44 -0700 (PDT)
In-Reply-To: <20170413.120925.2082322246776478766.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 13, 2017 at 9:09 AM, David Miller <davem@davemloft.net> wrote:
>
> ---
>
> v4:
>  - Fix MAC header adjustmnet before calling prog (David Ahern)
>  - Disable LRO when generic XDP is installed (Michael Chan)

I don't see where you are disabling LRO in the patch.

>  - Bypass qdisc et al. on XDP_TX and record the event (Alexei)
>  - Do not perform generic XDP on reinjected packets (DaveM)
>
