From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 16:07:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020160728.1d5a337e.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
	<20041020151448.51209278.davem@davemloft.net>
	<20041020223547.GJ29583@xi.wantstofly.org>
	<20041020155352.1c9b70f6.davem@davemloft.net>
	<20041020230405.GE995@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041020230405.GE995@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 01:04:05 +0200
Andi Kleen <ak@suse.de> wrote:

> Is it really necessary? Our struct sock is already bloated enough 
> as is ... If Lennert needs it for some obscure purpose it's probably
> better if he just does it locally.

There are a couple of "__u32" holes before pointers in tcp_opt
which is the space I was going to use for this new item.

tcp_opt will be getting smaller some time soon as well, since
we can consolidate most of the congestion control knobs into
a single set of datums or some kind of union.
