From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] Adding examples in ip man page on basic use of the
 ip command.
Date: Thu, 24 Nov 2011 19:12:48 +0000
Message-ID: <1322161968.2784.19.camel@bwh-desktop>
References: <4ECE31F6.4070002@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <shemminger@vyatta.com>
To: Alex Juncu <ajuncu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:24472 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab1KXTMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 14:12:52 -0500
In-Reply-To: <4ECE31F6.4070002@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-24 at 14:00 +0200, Alex Juncu wrote:
> ---
>   man/man8/ip.8 |   43 +++++++++++++++++++++++++++++++++++++++++++
>   1 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index a20eca7..99c8953 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -2855,6 +2855,49 @@ can be

Although it's customary to put EXAMPLES near the bottom of the page, I
suspect that the same users who are intimidated by the long usage
description are unlikely ever to get this far.  But I may be wrong;
maybe people do specifically look for this section.

Alternately, it may be more helpful to reorder the SYNOPSIS to emphasise
the most commonly used commands.

Ben.

>   .SS ip xfrm monitor - state monitoring for xfrm objects
>   The xfrm objects to monitor can be optionally specified.
> 
> +.SH EXAMPLES
> +.LP
> +To turn on an interface:
> +.RS
> +.nf
> +.B ip link set up dev eth0
> +.fi
> +.RE
> +.LP
> +To add an IPv4 address to an interface:
> +.RS
> +.nf
> +.B ip address add 141.85.37.42/24 dev eth0
> +.fi
> +.RE
> +.LP
> +To add a default route in the IPv4 routing table using a next hop IP 
> address:
> +.RS
> +.nf
> +.B ip route add  default via 141.85.37.1
> +.fi
> +.RE
> +.LP
> +Equivalent ways of listing address information for all the interfaces:
> +.RS
> +.nf
> +.B ip addr show
> +.fi
> +.RE
> +.LP
> +.RS
> +.nf
> +.B ip a s
> +.fi
> +.RE
> +.LP
> +.RS
> +.nf
> +.B ip a
> +.fi
> +.RE
> +.LP
> +
>   .SH HISTORY
>   .B ip
>   was written by Alexey N. Kuznetsov and added in Linux 2.2.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
