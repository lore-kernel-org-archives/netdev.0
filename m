From: Andi Kleen <ak@suse.de>
Subject: Re: way of figuring out total number of retransmitted packets on a TCP socket?
Date: Thu, 21 Oct 2004 01:27:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020232719.GG995@wotan.suse.de>
References: <20041020130134.GC24757@xi.wantstofly.org> <20041020151448.51209278.davem@davemloft.net> <20041020223547.GJ29583@xi.wantstofly.org> <20041020155352.1c9b70f6.davem@davemloft.net> <20041020230405.GE995@wotan.suse.de> <20041020160728.1d5a337e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, buytenh@wantstofly.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041020160728.1d5a337e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2004 at 04:07:28PM -0700, David S. Miller wrote:
> On Thu, 21 Oct 2004 01:04:05 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > Is it really necessary? Our struct sock is already bloated enough 
> > as is ... If Lennert needs it for some obscure purpose it's probably
> > better if he just does it locally.
> 
> There are a couple of "__u32" holes before pointers in tcp_opt
> which is the space I was going to use for this new item.

On 64bit you mean? That doesn't help the 32bit challenged users.

> 
> tcp_opt will be getting smaller some time soon as well, since
> we can consolidate most of the congestion control knobs into
> a single set of datums or some kind of union.

ok. good. I remember the times when you made jokes about the size
of TCBs in some other OSes. I bet we beat them all now in bloat, but it's 
good that things are shrinking again.

-Andi
