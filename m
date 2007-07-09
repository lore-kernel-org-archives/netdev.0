From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] Allow LSM to use IP address/port number.
Date: Mon, 9 Jul 2007 18:50:27 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707091842360.9417@d.namei>
References: <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp>
 <200707061343.03942.paul.moore@hp.com> <200707090533.l695X1PM059672@www262.sakura.ne.jp>
 <20070709.002629.28788394.davem@davemloft.net>
 <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Jul 2007, Tetsuo Handa wrote:

> It drops messages from unwanted IP address/ports.
> (To be exact, it doesn't drop, it just tells userland process
> not to use received messages by returning errors.)

This is broken.

You need to properly fail the network operation and ensure that the peers 
are appropriately notified using the standard failure paths, not just 
arbitrarily propagate errors to the local user.



- James
-- 
James Morris
<jmorris@namei.org>
