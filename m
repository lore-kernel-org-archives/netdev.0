From: "David S. Miller" <davem@davemloft.net>
Subject: Re: way of figuring out total number of retransmitted packets on a
 TCP socket?
Date: Wed, 20 Oct 2004 16:44:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020164451.7746b595.davem@davemloft.net>
References: <20041020130134.GC24757@xi.wantstofly.org>
	<20041020151448.51209278.davem@davemloft.net>
	<20041020223547.GJ29583@xi.wantstofly.org>
	<20041020155352.1c9b70f6.davem@davemloft.net>
	<20041020230405.GE995@wotan.suse.de>
	<20041020234423.GB31265@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041020234423.GB31265@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 01:44:23 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> My application is a large-ish streaming video and file download service,
> where I want to be able to automatically report on netblocks that are
> seeing unusual packet loss, and then use that data to alert our NOC
> and subsequently kick my transit providers with.

Isn't this what RSVP is for?  I realize that you may not be in
a position to use RSVP end-to-end as necessary, but watching for
retransmits by hand seems like simply a hackish way to do RSVP.

Furthermore, non-timeout based retransmits are actually normal even
on local subnets when a gigabit switch drops a packet to prevent
internal deadlocks and stuff like that.  I've seen this quite a bit.
