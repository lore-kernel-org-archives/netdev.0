From: Andrew Morton <akpm@osdl.org>
Subject: Re: kernel BUG at page_alloc.c:98 -- compiling with distcc
Date: Thu, 29 Apr 2004 16:26:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040429162632.689fa7fe.akpm@osdl.org>
References: <382320000.1082759593@taltos.ny.ficc.gs.com>
	<16527.4259.174536.629347@segfault.boston.redhat.com>
	<20040429210951.GB20453@logos.cnet>
	<20040429142807.1fa4c5ea.akpm@osdl.org>
	<20040429224936.GT29954@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: marcelo.tosatti@cyclades.com, jmoyer@redhat.com, carson@taltos.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20040429224936.GT29954@dualathlon.random>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrea Arcangeli <andrea@suse.de> wrote:
>
> On Thu, Apr 29, 2004 at 02:28:07PM -0700, Andrew Morton wrote:
> > just to exercise that code path a bit more.
> 
> what's the point of exercising that code path more? are you worried that
> there are bugs in it?

The only application which we know will exercise that code is the distcc
server.  Making that little change while testing the patch will increase
the chance of shaking out any problems.
