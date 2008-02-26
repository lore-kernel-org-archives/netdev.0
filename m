From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Netem] Fixed delay patch for netem
Date: Mon, 25 Feb 2008 16:54:28 -0800
Message-ID: <20080225165428.24ee90fe@extreme>
References: <682bc30a0802240611r5670fc9etba66cf86a9a78113@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@oss.sgi.com,
	netem@linux-foundation.org, netem@lists.linux-foundation.org
To: "Julio Kriger" <juliokriger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:59619 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750907AbYBZAyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 19:54:43 -0500
In-Reply-To: <682bc30a0802240611r5670fc9etba66cf86a9a78113@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 24 Feb 2008 12:11:16 -0200
"Julio Kriger" <juliokriger@gmail.com> wrote:

> Hi!
> I have created this patch to add a fixed delay on packet filtered by
> netem. Soon I will send the patch to iproute2.
> This patch comes from a need I have to delay all packets 50ms, beside
> the actual delay setting, like 30ms +- 15 ms. 

Why is 50ms + 30m +/- 15ms any different than 80ms +/- 15ms

> This strike, IMMHO, a
> missing point on gap reordering. If I set "gap 5 delay 10ms" every 5th
> (10th, 15th, ...) packet to go to be sent immediately and every other
> packet to be delayed by 10ms. This  is ok, but I also need a "fixed"
> delay of 50ms to be applied to all packets. Since netem can't be
> nested with himself (so I can do a fixed delay), I needed this new
> feature on netem.

The gap stuff is an awkward interface that should/could have been
done better.

> This patch was create with linux kernel version 2.6.24.2.
> I hope you like it, and it would be great if it goes shiped with the
> next version of the kernel :-))
> Regards,
> Julio Kriger

Maybe, but it is getting confusing with all the growth of parameters.
Probably time for a rethink.
