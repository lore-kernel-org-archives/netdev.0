From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: Avoid regenerating skb flow hash
 unless necessary
Date: Fri, 20 Jan 2017 09:31:55 -0800
Message-ID: <1484933515.16328.139.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170118210428.24006-1-acollins@cradlepoint.com>
         <CALx6S37Pnjyz6cpykKgy5JOU23MkH4EJ2Z+do+zVfXR08X5NYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Collins <acollins@cradlepoint.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36391 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdATRb5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:31:57 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so7355667pgf.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 09:31:57 -0800 (PST)
In-Reply-To: <CALx6S37Pnjyz6cpykKgy5JOU23MkH4EJ2Z+do+zVfXR08X5NYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-01-20 at 09:23 -0800, Tom Herbert wrote:

> So the perturbing of the hash is no longer needed for fq_codel?

Right, we never implemented a timer to change the perturbation anyway.

Note that local TCP flows now implement their own hash change when
needed.
