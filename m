From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 13:28:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922132816.1553292c.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
	<20040922111209.7887df53.davem@davemloft.net>
	<20040922195515.GA2619@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040922195515.GA2619@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 21:55:15 +0200
Andi Kleen <ak@suse.de> wrote:

> I must add that this is a CSA e1000 (directly integrated into
> the chipset and doesn't use PCI) and TSO doesn't seem to be 
> bring any advantage. On 2.6.5 the performance is the same
> with both TSO on or off.

That's expected.  It decreases the cpu and bus load, but if
those are capable of running the card full tilt already TSO
buys you nothing except spare cpu and memory cycles for
other work on your system.
