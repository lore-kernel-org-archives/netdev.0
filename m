From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: icmp_unreachable uses wrong ip
Date: Wed, 4 May 2005 02:35:33 +0300
Message-ID: <200505040235.33461.hasso@estpak.ee>
References: <1115040079.5620.11.camel@jeroens.office.netland.nl> <200505030944.49175.hasso@estpak.ee> <4277BFA6.8090306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "J. Simonetti" <jeroens@office.netland.nl>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4277BFA6.8090306@trash.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> But when multiple addresses are used the result can be even more
> confusing. I don't like inconsistent behaviour, and this patch works
> sometimes and sometimes it doesn't.

I see no behaviour you can define as "it doesn't work". Purpose of this 
patch is to provide info about links (not addresses, you can't have this 
info) used to forward packets and it does the job. 

> > And can you explain what theoretical possibilities router has to obtain
> > info what address was used as nexthop by neighbour?
>
> I can think of none.

Exactly.

regards,

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
