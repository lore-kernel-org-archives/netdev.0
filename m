From: Patrick McHardy <kaber@trash.net>
Subject: Re: NAT regression in next tree
Date: Fri, 19 Feb 2010 06:45:43 +0100
Message-ID: <4B7E2587.3050608@trash.net>
References: <20100216173658.519b6245@nehalam>	<201002171526.02493.arnd@arndb.de> <20100218173633.30bb8c41@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100218173633.30bb8c41@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Something in net-next tree broke bridging of virtual nets.
> My local VM's can no longer access external networks.
> 
> It is a NAT problem. One of the recent netfilter changes is causing
> the packets to not have there source address rewritten.
> 
> I see:
>     VM1  -- 192.168.100.0/24 -- HOST -- 192.168.1.0/24 -- ROUTER
>                            virbr0    eth0
> 
> Even a simple ping from VM1 doesn't get responded to because
> the 192.168.100.X source address is not getting rewritten.

I'll try to reproduce it locally. What is the HEAD of the broken
tree you're running?
