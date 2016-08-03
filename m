From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ipv4: panic in leaf_walk_rcu due to stale node pointer
Date: Wed, 3 Aug 2016 16:02:36 -0700
Message-ID: <CAKgT0Ud_Rou5qeF5xkdRqytBxyAYBEsRzN1F7MjTf0-Bk0H3_A@mail.gmail.com>
References: <1470233581-25728-1-git-send-email-dforster@brocade.com> <20160803.120143.377608139981878642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: dforster@brocade.com, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:32831 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758221AbcHCXCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 19:02:55 -0400
Received: by mail-io0-f176.google.com with SMTP id 38so257554327iol.0
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 16:02:37 -0700 (PDT)
In-Reply-To: <20160803.120143.377608139981878642.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 3, 2016 at 12:01 PM, David Miller <davem@davemloft.net> wrote:
> From: David Forster <dforster@brocade.com>
> Date: Wed, 3 Aug 2016 15:13:01 +0100
>
>> Panic occurs when issuing "cat /proc/net/route" whilst
>> populating FIB with > 1M routes.
>>
>> Use of cached node pointer in fib_route_get_idx is unsafe.
>  ...
>> Signed-off-by: Dave Forster <dforster@brocade.com>
>
> Alexander, please review.
>
> Thanks.

It took me a bit to recall how this worked.  This looks good to me.

By the way, I am glad you emailed my Gmail because my Mirantis email
is no more, I am back to working for Intel.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
