From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/2] cancel_rearming_delayed_work()
Date: Sun, 30 Jan 2005 22:41:49 -0800
Message-ID: <20050130224149.29bb18a0.akpm@osdl.org>
References: <200501310633.j0V6X0l01364@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, netdev@oss.sgi.com, arjan@infradead.org
In-Reply-To: <200501310633.j0V6X0l01364@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
>
>  Add library functions to reliably kill off a delayed work whose handler
>  re-adds the delayed work.  One for keventd, one for caller-owned workqueues.
>  DESC
>  make cancel_rearming_delayed_workqueue static
>  EDESC
>  From: Arjan van de Ven <arjan@infradead.org>
> 
>  cancel_rearming_delayed_workqueue() is only used inside workqueue.c; make
>  this function static (the more useful wrapper around it later in that
>  function remains non-static and exported)

hmm, actually, had I paid any attention to Arjan's patch I'd have dropped it ;)

cancel_rearming_delayed_workqueue() make sense and should be part of the
workqueue API, even if nothing uses it yet.

Whatever - we can fix that up sometime.
