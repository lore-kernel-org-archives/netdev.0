From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V4 8/8] net/mlx4_en: Set max rate-limit for a TC
Date: Sun, 1 Apr 2012 10:04:05 +0300
Message-ID: <CAJZOPZ+G_FSdbnBZAGFLwu+K98xBnH5BOos7DJ8Xek5dAYG+sQ@mail.gmail.com>
References: <1333033418-1669-9-git-send-email-amirv@mellanox.com>
	<1333034470.2325.751.camel@edumazet-glaptop>
	<4F74A988.1020103@mellanox.com>
	<20120329.172544.1685598375831468260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: amirv@mellanox.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	roland@purestorage.com, yevgenyp@mellanox.com, oren@mellanox.com,
	amirv@dev.mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41390 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750903Ab2DAHEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 03:04:06 -0400
Received: by lahj13 with SMTP id j13so1979045lah.19
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 00:04:05 -0700 (PDT)
In-Reply-To: <20120329.172544.1685598375831468260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 30, 2012 at 12:25 AM, David Miller <davem@davemloft.net> wrote:
>
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu, 29 Mar 2012 20:27:20 +0200
>
> > I was in a rush to send it on time and missed it (of course I tested
> > only tc 0 so didn't see it in my tests too).
>
> Being in a rush when you expect others to spend time reviewing your
> code is an extremely selfish act.

Hi Dave,

Yep, a mistake was done here, but as they say "only he who never does
never errs..."
so Amir will surely learn from that, and so am I - here wearing the
internal reviewer hat,
didn't review V4 deep enough. We spotted also some vzalloc calls in
the patches which
are under the HW QoS model debate and will fix there as well. V5 will
be also against
net-next but depending on your decision maybe it can still go to 3.4?

Or.
