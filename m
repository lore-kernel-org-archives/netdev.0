From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 2/9] use mmiowb in tg3.c
Date: Thu, 28 Oct 2004 16:42:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028164258.6cd01cd0.davem@davemloft.net>
References: <200410280721.i9S7Ld907983@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, jbarnes@engr.sgi.com,
        gnb@sgi.com, jbarnes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200410280721.i9S7Ld907983@mail.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 28 Oct 2004 00:19:40 -0700
akpm@osdl.org wrote:

> From: Jesse Barnes <jbarnes@engr.sgi.com>
> 
> This patch originally from Greg Banks.  Some parts of the tg3 driver depend
> on PIO writes arriving in order.  This patch ensures that in two key places
> using the new mmiowb macro.  This not only prevents bugs (the queues can be
> corrupted), but is much faster than ensuring ordering using PIO reads
> (which involve a few round trips to the target bus on some platforms).
> 
> Arthur has another patch that uses mmiowb in tg3 that he posted earlier as
> well.
> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Ok, applied.
