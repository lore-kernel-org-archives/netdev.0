From: David Miller <davem@davemloft.net>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 15:23:52 -0400 (EDT)
Message-ID: <20120418.152352.748260330741957708.davem@davemloft.net>
References: <CADZpyixnQMM5WFWLyvEQ=D-tvrqFGe4PC5WdUzxVtdL96NODJQ@mail.gmail.com>
	<20120418.133102.1711079292327461659.davem@davemloft.net>
	<CADZpyizwozRjYOvOads0KkqRr2quTo532TC=Ff=cw0sGc3OCQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, netdev@vger.kernel.org,
	penguin-kernel@i-love.sakura.ne.jp, linux-api@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jengelh@medozas.de, w@1wt.eu,
	alan@lxorguk.ukuu.org.uk
To: carlos@systemhalted.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab2DRT0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:26:36 -0400
In-Reply-To: <CADZpyizwozRjYOvOads0KkqRr2quTo532TC=Ff=cw0sGc3OCQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Carlos O'Donell" <carlos@systemhalted.org>
Date: Wed, 18 Apr 2012 14:48:43 -0400

> POSIX doesn't exist in a vacuum, we need to harmonize reality with the
> standard. If an implementation exists where sun_path has no
> null-terminator then it is useful to have POSIX clarify that
> null-termination is implementation defined behaviour, just like it
> says that sun_path's length undefined. Under "Application Usage" or
> "Examples" it's valid to talk about specific implementations.
> 
> See: http://pubs.opengroup.org/onlinepubs/007904975/basedefs/sys/un.h.html,
> where it talks about BSD in the "Application Usage." It's about time
> we some "Linux this" and "Linux that" in there.

Ok, thanks for explaining.
