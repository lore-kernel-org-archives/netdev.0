From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize
 modifications
Date: Thu, 04 Feb 2010 15:23:34 -0500
Message-ID: <1265315014.2861.531.camel@tonnant>
References: <20100203203929.GA6168@x200> <4B6AF36A.3050402@trash.net>
	 <4B6AFE22.20304@trash.net>  <20100204194744.GA4185@x200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100204194744.GA4185@x200>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-02-04 at 21:47 +0200, Alexey Dobriyan wrote:
> On Thu, Feb 04, 2010 at 06:04:34PM +0100, Patrick McHardy wrote:
> > Patrick McHardy wrote:
> > > Alexey Dobriyan wrote:

> > Additionally I removed reinitializing the hash random value when
> > changing the hash size since that also requires to rehash in all
> > namespaces.
> 
> I'm not fond of this, because we're not even closely going to allow changing
> hashtable size per-netns. As such having actual per-netns hashtable size
> just slows down everything.

Are you sure, as compared with a shared global size that this is really
going to slow things down all that much? We already need to poke in that
struct to pull out various things just hash. I haven't profiled to see.

Jon.


