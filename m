From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 11:12:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922111209.7887df53.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040922140000.GD27432@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 16:00:00 +0200
Andi Kleen <ak@suse.de> wrote:

> I tried it with rc2bk8 again and the performance is much better (22MB/s) 
> that what I got earlier with 2.6.8rc2, but still far below what 2.6.5 gets 
> on the same hardware (68MB/s) 
> 
> Both tests with netperf over e1000.

Great, please try one more thing to help me narrow this down.
Rerun your e1000 tests after going:

ethtool -K eth? tso off

and see if that gets you back to 2.6.5 era performance.

Thanks Andi.
