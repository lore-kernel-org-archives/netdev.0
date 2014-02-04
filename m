From: sohny thomas <sohny.kernel@gmail.com>
Subject: Re: [PATCH] ipv6: default route for link local address is not added
 while assigning a address
Date: Wed, 05 Feb 2014 00:07:04 +0530
Message-ID: <52F13350.2020300@gmail.com>
References: <52E8A2AA.3090507@linux.vnet.ibm.com> <52E8DA37.7010208@6wind.com> <20140130232909.GH25336@order.stressinduktion.org> <52EF42FF.60907@linux.vnet.ibm.com> <52EFB454.1040908@6wind.com> <20140203160838.GA17999@order.stressinduktion.org> <52EFC324.1030102@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: nicolas.dichtel@6wind.com,
	Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EFC324.1030102@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 03 February 2014 09:56 PM, Nicolas Dichtel wrote:
>> 4) make flush not remove the fe80::/64 address
>>
>>     Least favourable to me. I guess this also woud need iproute change
>>     and seems most difficult to do.
> Why using this command 'ip -6 route flush proto static' isn't possible?
Ok I tried this and it works fine ( i.e, leaves out removing Link Local 
route), but I think this is a workaround to a problem that occurs if 
anyone actually deletes a Link local route

> I think that we know what kind of route is added for these TAHI tests,
> hence
> it's better to remove only routes added manually (or by a routing daemon if
> it's the case).
> Removing kernel routes may hide bugs: imagine the kernel adds a wrong
> route,
> TAHI will not detect it.
