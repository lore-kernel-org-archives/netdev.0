From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Thu, 21 Oct 2004 01:44:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020234423.GB31265@xi.wantstofly.org>
References: <20041020130134.GC24757@xi.wantstofly.org> <20041020151448.51209278.davem@davemloft.net> <20041020223547.GJ29583@xi.wantstofly.org> <20041020155352.1c9b70f6.davem@davemloft.net> <20041020230405.GE995@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20041020230405.GE995@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 21, 2004 at 01:04:05AM +0200, Andi Kleen wrote:

> Is it really necessary? Our struct sock is already bloated enough 
> as is ... If Lennert needs it for some obscure purpose it's probably
> better if he just does it locally.

My application is a large-ish streaming video and file download service,
where I want to be able to automatically report on netblocks that are
seeing unusual packet loss, and then use that data to alert our NOC
and subsequently kick my transit providers with.

Determining optimal routing within the internet is a somewhat of random
process, and a lot of ISPs just always use the route with the shortest
AS-path even though a lot of times that turns out not to be the best
path at all (in terms of latency/loss.)


--L
