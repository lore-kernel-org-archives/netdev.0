From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 16:42:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020164241.5f29cea5.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
	<20041020151448.51209278.davem@davemloft.net>
	<20041020223547.GJ29583@xi.wantstofly.org>
	<20041020155352.1c9b70f6.davem@davemloft.net>
	<20041020230405.GE995@wotan.suse.de>
	<20041020160728.1d5a337e.davem@davemloft.net>
	<20041020232719.GG995@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, buytenh@wantstofly.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041020232719.GG995@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 01:27:19 +0200
Andi Kleen <ak@suse.de> wrote:

> ok. good. I remember the times when you made jokes about the size
> of TCBs in some other OSes. I bet we beat them all now in bloat, but it's 
> good that things are shrinking again.

Nope, Solaris's TCB is still 3 times the size of ours.

BSD's is about the same size, yet they lack most of the
congestion control and ECN functionality we have.
