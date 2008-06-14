From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [2/3] POHMELFS: Documentation.
Date: Sat, 14 Jun 2008 23:25:31 +0400
Message-ID: <20080614192531.GA15221@2ka.mipt.ru>
References: <20080613163700.GA25860@2ka.mipt.ru> <20080613164110.GB26166@2ka.mipt.ru> <20080614021547.GC32232@shareable.org> <20080614065616.GA32585@2ka.mipt.ru> <1213469136.7149.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1213469136.7149.36.camel@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 14, 2008 at 02:45:36PM -0400, Trond Myklebust (trond.myklebust@fys.uio.no) wrote:
> 
> You're confusing write gathering with asynchronous I/O...
> 
> NFS attempts to send multiple contiguous pages in one I/O request, and
> so it has a mechanism for collecting them and dispatching the I/O as
> soon as we have enough pages for an RPC call.
> 
> The actual RPC call is then handled by the sunrpc layer and is done
> fully asynchronously using non-blocking I/O.

Well, yes, I did not dig into rpc as is deep enough, but checked how
callbacks are prepared in respect to ioflags namely RPC_FLAGS_ASYNC. I
was confused with the fact, that system did not yet process request, but
accounted stats for it, but likely that stats are just intended to
show exactly what was queued for (later) processing.

-- 
	Evgeniy Polyakov
