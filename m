From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: randomize tcp timestamp offsets for
 each connection
Date: Tue, 29 Nov 2016 10:06:03 -0800
Message-ID: <1480442763.18162.147.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480434342-12367-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Mirja =?ISO-8859-1?Q?K=FChlewind?=
        <mirja.kuehlewind@tik.ee.ethz.ch>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34677 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754392AbcK2SGG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:06:06 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so8723479pfb.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:06:05 -0800 (PST)
In-Reply-To: <1480434342-12367-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-29 at 16:45 +0100, Florian Westphal wrote:
> jiffies based timestamps allow for easy inference of number of devices
> behind NAT translators and also makes tracking of hosts simpler.
> 
> commit ceaa1fef65a7c2e ("tcp: adding a per-socket timestamp offset")
> added the main infrastructure that is needed for per-connection ts
> randomization, in particular writing/reading the on-wire tcp header
> format takes the offset into account so rest of stack can use normal
> tcp_time_stamp (jiffies).
> 
> So only two items are left:
>  - add a tsoffset for request sockets
>  - extend the tcp isn generator to also return another 32bit number
>    in addition to the ISN.
> 
> Re-use of ISN generator also means timestamps are still monotonically
> increasing for same connection quadruple, i.e. PAWS will still work.
> 
> Includes fixes from Eric Dumazet.
> 
> Cc: Mirja Kühlewind <mirja.kuehlewind@tik.ee.ethz.ch>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Very nice work, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
