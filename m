From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: [patch] add iocb to network protocols
Date: Fri, 11 Oct 2002 06:27:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021011062709.A14784@redhat.com>
References: <20021010183528.A13432@redhat.com> <200210110931.KAA19428@gw.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Steven Whitehouse <steve@gw.chygwyn.com>
Content-Disposition: inline
In-Reply-To: <200210110931.KAA19428@gw.chygwyn.com>; from steve@gw.chygwyn.com on Fri, Oct 11, 2002 at 10:31:23AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 11, 2002 at 10:31:23AM +0100, Steven Whitehouse wrote:
> Given two aio requests, A and B both for the same socket, can I be sure
> that they will complete in the order that I submit them ? Can I also
> be sure that parts of the I/O request for A will not be mixed up with
> B ? Will that still be true if one of the requests is aio and one a "normal"
> send/recvmsg() for example ?

The POSIX standard does not seem to require any ordering between requests, 
and some implementations take advantage of this by using threads to execute 
requests.  That said, providing intra request ordering for sockets is easy 
to do, and is one of the guarantees I'm trying to make as it allows the 
implementation to provide the same semantics as are required for things 
like zero copy tx.

		-ben
-- 
"Do you seek knowledge in time travel?"
