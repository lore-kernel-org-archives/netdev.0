From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Missing unlock in policy timer
Date: Fri, 23 Jul 2004 13:34:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723133428.5474c751.davem@redhat.com>
References: <20040723110626.GA31264@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040723110626.GA31264@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 23 Jul 2004 21:06:26 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is one of those cases where the cure is worse than the disease :)
> I added read locks in the policy timer to close an unlikely race, but
> I missed an unlock on the expire path which leads to all sort of weird
> things.
> 
> I'll stay away from the timers for a while :)

Hehe, applied.  Thanks Herbert.
