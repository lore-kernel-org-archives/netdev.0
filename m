From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen patch available for perusal.
Date: Fri, 03 Nov 2006 08:34:37 -0800
Message-ID: <454B6F9D.8030300@candelatech.com>
References: <45468F2E.4060809@candelatech.com>	<17736.54766.657083.873206@robur.slu.se>	<4548F166.1020001@candelatech.com> <17739.9326.620495.394705@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:5760 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1753356AbWKCQdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 11:33:16 -0500
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17739.9326.620495.394705@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> Ben Greear writes:
>
>  > I'd be thrilled to have the receive logic go into pktgen, even if it was #if 0 with a comment
>  > showing how to patch dev.c to get it working.  It would make my out-of-tree patch smaller
>  > and should help others who are doing research and driver development...
>
>
>  Just an idea... RX part is pretty separate from TX. How about if we keep the 
>  this code in a small seprate optional module? It can developed into some general 
>  RX probe.
>   
It requires a hook in dev.c, or at least that is the only way I can 
think to implement it.
I don't think that hook is going to be allowed into the kernel, so the 
best I was hoping for
was to have the code in pktgen with #if 0 and let users patch their 
kernel to add the
hook...

Ben

>  Cheers.
> 						--ro
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


