From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 21:55:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922195515.GA2619@wotan.suse.de>
References: <20040920063012.GL2825@krispykreme> <20040920203021.GD4242@wotan.suse.de> <20040921155835.18aee381.davem@davemloft.net> <20040922140000.GD27432@wotan.suse.de> <20040922111209.7887df53.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040922111209.7887df53.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2004 at 11:12:09AM -0700, David S. Miller wrote:
> On Wed, 22 Sep 2004 16:00:00 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > I tried it with rc2bk8 again and the performance is much better (22MB/s) 
> > that what I got earlier with 2.6.8rc2, but still far below what 2.6.5 gets 
> > on the same hardware (68MB/s) 
> > 
> > Both tests with netperf over e1000.
> 
> Great, please try one more thing to help me narrow this down.
> Rerun your e1000 tests after going:
> 
> ethtool -K eth? tso off
> 
> and see if that gets you back to 2.6.5 era performance.

With tso off i get the same performance as on 2.6.5.

I must add that this is a CSA e1000 (directly integrated into
the chipset and doesn't use PCI) and TSO doesn't seem to be 
bring any advantage. On 2.6.5 the performance is the same
with both TSO on or off.

-Andi
