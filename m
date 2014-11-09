From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dccp: Convert DCCP_WARN to
 net_warn_ratelimited
Date: Sat, 08 Nov 2014 20:42:02 -0500 (EST)
Message-ID: <20141108.204202.2273082249078358608.davem@davemloft.net>
References: <1415230929.6634.38.camel@perches.com>
	<20141106.151149.1321164537677873976.davem@davemloft.net>
	<1415307221.21526.0.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gerrit@erg.abdn.ac.uk
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415307221.21526.0.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 06 Nov 2014 12:53:41 -0800

> Remove the dependency on the "warning" sysctl (net_msg_warn)
> which is only used by the LIMIT_NETDEBUG macro.
> 
> Convert the LIMIT_NETDEBUG use in DCCP_WARN to the more
> common net_warn_ratelimited mechanism.
> 
> This still ratelimits based on the net_ratelimit()
> function, but removes the check for the sysctl.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.

> What about the LIMIT_NETDEBUG stuff now?
> 
> Maybe all of them might as well be net_dbg_ratelimited
> even if it changes some of the logging levels.

I think a straight conversion to net_dbg_ratelimited would
be fine.
