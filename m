From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] ixgbevf: get rid of custom busy polling code
Date: Fri, 3 Feb 2017 13:42:12 -0800
Message-ID: <CAKgT0UcKaagCJvktEnHxQwaGFCJcv689Lo1DpugqdpM+fdzTnA@mail.gmail.com>
References: <1486083558.21871.42.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36098 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752291AbdBCVmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:42:13 -0500
Received: by mail-io0-f195.google.com with SMTP id q20so3539247ioi.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 13:42:13 -0800 (PST)
In-Reply-To: <1486083558.21871.42.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2017 at 4:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In linux-4.5, busy polling was implemented in core
> NAPI stack, meaning that all custom implementation can
> be removed from drivers.
>
> Not only we remove lot's of code, we also remove one lock
> operation in fast path, and allow GRO to do its job.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Looks good to me

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
