From: James Morris <jmorris@redhat.com>
Subject: Re: TCP crashes when cycling loopback interface.
Date: Fri, 22 Oct 2004 23:23:10 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0410222322460.19110-100000@thoron.boston.redhat.com>
References: <20041023012018.GA15257@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041023012018.GA15257@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 23 Oct 2004, Herbert Xu wrote:

> > KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tcp_timer.c (322)
> 
> James, are you still getting this crash?

Yes.

> If so can you please apply this patch and see if it trips? If it
> does then your problem has been found and fixed.

Did not seem to trip during a crash in 2.6.9-mm1


- James
-- 
James Morris
<jmorris@redhat.com>
