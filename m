From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] Allow LSM to use IP address/port number.
Date: Mon, 9 Jul 2007 16:05:38 -0700
Message-ID: <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net>
References: <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp>
	<200707061343.03942.paul.moore@hp.com>
	<200707090533.l695X1PM059672@www262.sakura.ne.jp>
	<20070709.002629.28788394.davem@davemloft.net>
	<200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
	<Line.LNX.4.64.0707091842360.9417@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <Line.LNX.4.64.0707091842360.9417@d.namei>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Jul 2007 18:50:27 -0400 (EDT)
James Morris <jmorris@namei.org> wrote:

> On Mon, 9 Jul 2007, Tetsuo Handa wrote:
> 
> > It drops messages from unwanted IP address/ports.
> > (To be exact, it doesn't drop, it just tells userland process
> > not to use received messages by returning errors.)
> 
> This is broken.
> 
> You need to properly fail the network operation and ensure that the peers 
> are appropriately notified using the standard failure paths, not just 
> arbitrarily propagate errors to the local user.

Isn't it better to hook into existing netfilter infrastructure somehow?
Just filtering by ports or IP addresses is tip of bigger security isolation issues.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
