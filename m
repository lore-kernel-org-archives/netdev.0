From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 04/10] b44 bounce buffering fix
Date: Mon, 24 Jan 2005 19:07:02 -0800
Message-ID: <20050124190702.62d84861.akpm@osdl.org>
References: <200501250257.j0P2vdl20257@mail.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com, pp@ee.oulu.fi
In-Reply-To: <200501250257.j0P2vdl20257@mail.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
>
> From: Pekka Pietikainen <pp@ee.oulu.fi>
> 
>  b44 allocates a full TX ring worth of bounce buffers to work around a DMA
>  addressing limitation.  It should do a bunch of smaller consistent
>  allocations instead of one huge one.

err, this one was a leak.  Please ignore.  I think.  Driver remains fscked.
