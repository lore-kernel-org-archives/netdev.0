From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 16:00:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922140000.GD27432@wotan.suse.de>
References: <20040920063012.GL2825@krispykreme> <20040920203021.GD4242@wotan.suse.de> <20040921155835.18aee381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040921155835.18aee381.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Sep 21, 2004 at 03:58:35PM -0700, David S. Miller wrote:
> On Mon, 20 Sep 2004 22:30:21 +0200
> Andi Kleen <ak@suse.de> wrote:
> 
> > I see the same problem here, but it's even worse. I only get 150-200KB/s
> > sending data with scp from a fast machine with e1000 with a gigabit link. 
> > netperf also gives only 250KB/s. 
> 
> So I re-enabled TSO support in the loopback driver to try and
> reproduce this, but I can't.
> 
> There has been a lot of churn in this area so please make sure you
> are using the latest sources, all of my current TSO fixes are in
> Linus's BK tree.

I tried it with rc2bk8 again and the performance is much better (22MB/s) 
that what I got earlier with 2.6.8rc2, but still far below what 2.6.5 gets 
on the same hardware (68MB/s) 

Both tests with netperf over e1000.

> And, take the patch below and do a loopback bandwidth test before
> and after the patch is applied.  Do things slow down when loopback
> has TSO enabled just as it does for your gigabit interfaces?

Without TSO ~755MB/s, with TSO ~600-620MB/s (results seem to be a bit
variable). 

-Andi
