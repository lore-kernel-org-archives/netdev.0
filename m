From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] RFC: have tcp_recvmsg() check kthread_should_stop() and treat it as if it were signalled
Date: Sat, 09 Jun 2007 11:30:04 +1000
Message-ID: <E1HwpmG-0008LW-00@gondolin.me.apana.org.au>
References: <20070608123527.9b4cdafe.jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-cifs-client@lists.samba.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: jlayton@redhat.com (Jeff Layton)
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070608123527.9b4cdafe.jlayton@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please cc networking patches to netdev@vger.kernel.org.

Jeff Layton <jlayton@redhat.com> wrote:
> 
> The following patch is a first stab at removing this need. It makes it
> so that in tcp_recvmsg() we also check kthread_should_stop() at any
> point where we currently check to see if the task was signalled. If
> that returns true, then it acts as if it were signalled and returns to
> the calling function.

This just doesn't seem to fit.  Why should networking care about kthreads?

Perhaps you can get kthread_stop to send a signal instead?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
