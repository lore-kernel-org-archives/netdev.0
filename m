From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Tue, 27 Apr 2004 22:02:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16527.4259.174536.629347@segfault.boston.redhat.com>
References: <382320000.1082759593@taltos.ny.ficc.gs.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carson Gaspar <carson@taltos.org>
In-Reply-To: <382320000.1082759593@taltos.ny.ficc.gs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>FYI, we see the exact same panic with the tg3 driver using 2.4.25 and 
>distcc with sendfile(). The bcm5700 driver also panics, but I haven't 
>captured a panic message to be certain it's the same bug.

>kernel BUG at page_alloc.c:98!

Andrea fixed this in his tree by deferring the page free to process context
instead of BUG()ing on PageLRU(page).

-Jeff
