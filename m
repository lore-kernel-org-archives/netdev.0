From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 09:06:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008090610.70d7e183@pirandello>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
	<20041007224422.1c1bea95@jack.colino.net>
	<20041007214505.GB31558@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mpm@selenic.com, akpm@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20041007214505.GB31558@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Oct 2004 at 23h10, Andi Kleen wrote:

Hi, 

> > This patch should do that. It works OK for me, but I'd like it
> > checked before sent upstream...
> > 
> > However, it doesn't fix the hang. it looks like this hang is really
> > coming from sungem.
> 
> IMHO it's not needed. Taking xmit_lock is harmless even when
> the NETIF_F_LLTX flag is set. 

Should that be completely dropped, or is it still ok ? (I think
differenciating action based on hard_start_xmit status, that is, don't
goto repeat undefinitely when NETDEV_TX_BUSY, could be a good idea).
I mean, should I rework that patch, forget about it or leave it as-is?

Concerning the hang, I see that Andrew has put my first patch, the one
checking for netif_carrier_ok(), in his tree. Is it an OK solution from
your (net dev hackers) point of view?

Thanks,
-- 
Colin
