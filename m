From: Andi Kleen <ak@suse.de>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Mon, 20 Sep 2004 22:30:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920203021.GD4242@wotan.suse.de>
References: <20040920063012.GL2825@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
Content-Disposition: inline
In-Reply-To: <20040920063012.GL2825@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 04:30:13PM +1000, Anton Blanchard wrote:
> 
> Hi,
> 
> I just tried latest 2.6.9-rc2-BK on a machine with an e1000 on it. With
> TSO off it does about 100MB/sec. With TSO on it does between 1MB/sec and
> 10MB/sec.

I see the same problem here, but it's even worse. I only get 150-200KB/s
sending data with scp from a fast machine with e1000 with a gigabit link. 
netperf also gives only 250KB/s. 

-Andi
