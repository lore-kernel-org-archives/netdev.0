From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Re: Cherry pick commit *net: better skb->sender_cpu and skb->napi_id
 cohabitation* to 4.4 series?
Date: Thu, 1 Jun 2017 19:32:35 +0200
Message-ID: <409abefe-62ff-563a-b5c6-a3149ae672e0@molgen.mpg.de>
References: <987d9047-08ac-0d53-2d1f-ef9189988ee2@molgen.mpg.de>
 <20170601.121935.1801387892378122014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        ast@kernel.org, it+linux-netdev@molgen.mpg.de,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:44656 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751096AbdFARci (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 13:32:38 -0400
In-Reply-To: <20170601.121935.1801387892378122014.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,


On 06/01/17 18:19, David Miller wrote:
> Neither of us have anything to do with the 4.4 -stable series.  We only
> manage stable backport submissions for the most recent two releases.

Thank you for the prompt response. Should the netdev FAQ be updated then 
to contain that information?

> Q: How can I tell what patches are queued up for backporting to the
>    various stable releases?
> 
> A: Normally Greg Kroah-Hartman collects stable commits himself, but
>    for networking, Dave collects up patches he deems critical for the
>    networking subsystem, and then hands them off to Greg.
> 
>    There is a patchworks queue that you can see here:
>         http://patchwork.ozlabs.org/bundle/davem/stable/?state=*
> 
>    It contains the patches which Dave has selected, but not yet handed
>    off to Greg.  If Greg already has the patch, then it will be here:
>         https://git.kernel.org/pub/scm/linux/kernel/git/stable/stable-queue.git
> 
>    A quick way to find whether the patch is in this stable-queue is
>    to simply clone the repo, and then git grep the mainline commit ID, e.g.
> 
>         stable-queue$ git grep -l 284041ef21fdf2e
>         releases/3.0.84/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
>         releases/3.4.51/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
>         releases/3.9.8/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
>         stable/stable-queue$


Kind regards,

Paul


[1] Documentation/networking/netdev-FAQ.txt
