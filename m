From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: Removing busy-spin in pktgen.
Date: Tue, 24 Oct 2006 09:34:38 -0700
Message-ID: <453E409E.9010002@candelatech.com>
References: <453D582C.9020705@candelatech.com>	<17725.55765.509953.762136@robur.slu.se> <20061024.031455.55723788.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:23988 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932437AbWJXQdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 12:33:20 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061024.031455.55723788.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Robert Olsson <Robert.Olsson@data.slu.se>
> Date: Tue, 24 Oct 2006 11:16:05 +0200
>
>   
>>  My first instinct is to avoid the hook in general code and pktgen let spin 
>>  to only affect testing.
>>     
>
> Mine too.
>
> Why make everyone in the world make that check in netif_wake_queue(),
> or wherever, when %99.99999999999 of the time it'll never be used?
>   
It could be a compile-time option, and even if compiled in, it should 
only be an if  branch on
a pointer.  Is there any noticeable performance hit for an if check if 
you wrap it with unlikely?

Thanks,
Ben

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


