From: Patrick McHardy <kaber@trash.net>
Subject: Re: icmp_unreachable uses wrong ip
Date: Tue, 03 May 2005 20:15:02 +0200
Message-ID: <4277BFA6.8090306@trash.net>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505022038.22014.hasso@estpak.ee> <4276A400.2050306@trash.net> <200505030944.49175.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200505030944.49175.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> Patrick McHardy wrote:
>>
>>Your patch can't guarantee that the address used is the same that was
>>used as nexthop by the previous hop in the path when multiple addresses
>>are configured on the incoming interface. So I don't think it achieves
>>much of your goal of making debugging complicated topologies easier.
> 
> At first I don't care what was used as nexthop. I want to know which 
> physical link was used. Having multiple addresses in the same link is more 
> corner case in core network anyway.

But when multiple addresses are used the result can be even more
confusing. I don't like inconsistent behaviour, and this patch works
sometimes and sometimes it doesn't.

> And can you explain what theoretical possibilities router has to obtain info 
> what address was used as nexthop by neighbour?

I can think of none.

Regards
Patrick
