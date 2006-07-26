From: Tushar Gohad <tgohad@mvista.com>
Subject: Re: [PATCH 1/5] [IPV6]: Remove ndiscs rt6_lock dependency
Date: Wed, 26 Jul 2006 16:34:03 -0700
Message-ID: <44C7FBEB.30708@mvista.com>
References: <20060726221100.325687073@postel.suug.ch>	<20060726221849.188750063@postel.suug.ch> <20060726.152845.71540437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:43097 "EHLO
	gateway-1237.mvista.com") by vger.kernel.org with ESMTP
	id S1750722AbWGZXbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 19:31:15 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060726.152845.71540437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Are these changes scheduled to go into 2.6.18-rcX or 2.6.19?

Thanks.
- Tushar

David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 27 Jul 2006 00:00:01 +0200
> 
> 
>>(Ab)using rt6_lock wouldn't work anymore if rt6_lock is
>>converted into a per table lock.
>>
>>Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> 
> This one looks great.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

