From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 13:24:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008132402.64984528.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
	<20031008183742.GA24822@wotan.suse.de>
	<20031008122223.1ba5ac79.davem@redhat.com>
	<20031008202248.GA15611@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, modica@sgi.com, johnip@sgi.com, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008202248.GA15611@oldwotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 22:22:48 +0200
Andi Kleen <ak@suse.de> wrote:

> It's not that it's a new problem - we had this since the Alpha port
> and it hasn't gotten more urgent suddenly.

Frankly, I just want to shut all the ia64 users up because they keep
barking due to the kernel unaligned trap message that port spits out.

> Hmm - you mean it allocates a full page and does suballocation by itself?

We could write some helper routines.

> The suballocation would need to be per CPU to be SMP efficient I guess,
> which would complicate it.

Andi, stop right there, we're talking about mitigating the horrible
performance some $6.00 USD Taiwaneese network cards get on expensive
ia64 systems.  How much effort do you think we should drain into
optimizing this? :-)
