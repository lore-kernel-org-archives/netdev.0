From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen patch available for perusal.
Date: Wed, 01 Nov 2006 11:11:34 -0800
Message-ID: <4548F166.1020001@candelatech.com>
References: <45468F2E.4060809@candelatech.com> <17736.54766.657083.873206@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:18650 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S2992719AbWKATLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 14:11:37 -0500
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17736.54766.657083.873206@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
>  > I've completed the first pass of my changes to pktgen in 2.6.18.
>  > Many of these features are probably DOA based on previous conversations,
>  > but perhaps this will help someone....
> 
>  Thanks. Well sometimes there is a need to capture and drop pkts and various 
>  points, so it handy to have code fragments ready and just add the hook when 
>  it's needed in driver or rx softirq etc.

I'd be thrilled to have the receive logic go into pktgen, even if it was #if 0 with a comment
showing how to patch dev.c to get it working.  It would make my out-of-tree patch smaller
and should help others who are doing research and driver development...

If you'd accept a patch like this, please let me know.

>  > Changes:
>  > * use a nano-second timer based on the scheduler timer (TSC) for relative times, instead of get_time_of_day.
> 
>  Any chance you extract this one so we can compare with get_time_of_day. This pops up
>  in the profiles and TX numbers are not what used to be.

I'll work on that.

Thanks,
Ben

> 
>  Cheers.
> 					--ro
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

