From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPV4] Always set hoplimit
Date: Tue, 18 Nov 2003 16:59:09 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118165909.788d5388.davem@redhat.com>
References: <20031113110438.GA29522@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031113110438.GA29522@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 13 Nov 2003 22:04:38 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Is there any reason why local/broadcast packets should have a ttl of zero?
> This is the result of the HOPLIMIT change as those packets doesn't get
> their HOPLIMIT set.  This patch sets it for them.
> 
> Am I missing something?

I don't believe I changed this behavior intentionally.  Let me
look into the revision history to verify that.  I'm likely going
to apply your fix tonight, thanks.

Although it is an interesting question because both broadcasts and
locally destined packets have no reason to make it past the local
subnet and thus have their TTL/HOPLIMIT decremented or tested.  I
therefore cannot imagine a case where the current behavior would cause
a problem.

Did you run into an actual problem that led you to this issue?  If
so, what was it?  Or was this just determined by pure code review?
