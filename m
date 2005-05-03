From: Patrick McHardy <kaber@trash.net>
Subject: Re: icmp_unreachable uses wrong ip
Date: Wed, 04 May 2005 01:37:40 +0200
Message-ID: <42780B44.8040803@trash.net>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505030944.49175.hasso@estpak.ee> <4277BFA6.8090306@trash.net> <200505040235.33461.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hasso Tepper <hasso@estpak.ee>
In-Reply-To: <200505040235.33461.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hasso Tepper wrote:
> Patrick McHardy wrote:
> 
>>But when multiple addresses are used the result can be even more
>>confusing. I don't like inconsistent behaviour, and this patch works
>>sometimes and sometimes it doesn't.
> 
> 
> I see no behaviour you can define as "it doesn't work". Purpose of this 
> patch is to provide info about links (not addresses, you can't have this 
> info) used to forward packets and it does the job. 

Well, arguably it can be called "doesn't work" if addresses not used
at all during transmit of the packet show up in traceroute.

Regards
Patrick
