From: Marco Fais <marco.fais@abbeynet.it>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Mon, 05 Apr 2004 12:47:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <4071394A.1060007@abbeynet.it>
References: <406D3E8F.20902@abbeynet.it> <20040402153628.4a09d979.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040402153628.4a09d979.akpm@osdl.org>
List-Id: netdev.vger.kernel.org

Andrew Morton ha scritto:

>>kernel BUG at page_alloc.c:98!
> uh-oh.

That was the same thing that I've said when I saw all the leds blinking 
in *all* the keyboards ... :)

> distcc uses sendfile().  The 8139too hardware and driver are
> zerocopy-capable so the kernel uses zerocopy direct-from-user-pages for
> sendfile().

Ok. Other servers with e100 driver doesn't show the problem. This means 
that they're not "zerocopy-capable"?

> This was all discussed fairly extensively a couple of years back and I
> thought it ended up being fixed.

There are any workarounds for this, until the problem is corrected?

Thank you very much.
