From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 02/17] tipc: Fix build.
Date: Tue, 26 Aug 2014 09:15:58 -0400
Message-ID: <20140826131557.GA797@hmsreliant.think-freely.org>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
 <1408745360-23560-3-git-send-email-jon.maloy@ericsson.com>
 <20140825102142.GA7151@hmsreliant.think-freely.org>
 <20140825.114420.77676883396367108.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38002 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbaHZNQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 09:16:12 -0400
Content-Disposition: inline
In-Reply-To: <20140825.114420.77676883396367108.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2014 at 11:44:20AM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 25 Aug 2014 06:21:42 -0400
> 
> > On Fri, Aug 22, 2014 at 06:09:05PM -0400, Jon Maloy wrote:
> >> From: "David S. Miller" <davem@davemloft.net>
> >> 
> >> Missing semicolon in range check fix.
> >> 
> >> Signed-off-by: David S. Miller <davem@davemloft.net>
> >> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> >> ---
> >>  net/tipc/port.h |    3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >> 
> >> diff --git a/net/tipc/port.h b/net/tipc/port.h
> >> index a69118f..3087da3 100644
> >> --- a/net/tipc/port.h
> >> +++ b/net/tipc/port.h
> >> @@ -182,8 +182,9 @@ static inline int tipc_port_importance(struct tipc_port *port)
> >>  static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
> >>  {
> >>  	if (imp > TIPC_CRITICAL_IMPORTANCE)
> >> -		return -EINVAL
> >> +		return -EINVAL;
> >>  	msg_set_importance(&port->phdr, (u32)imp);
> >> +	return 0;
> >>  }
> >>  
> > Fold this in with the previous patch to avoid a FTBFS during a bisect.
> 
> See his header posting, these are changes already in mainline that hadn't
> hit net-next yet.
My bad, thanks
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
