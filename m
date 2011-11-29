From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] Adding examples in ip man page on basic use of the
 ip command.
Date: Mon, 28 Nov 2011 17:39:17 -0800
Message-ID: <20111128173917.30e7a025@nehalam.linuxnetplumber.net>
References: <4ECE31F6.4070002@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alex Juncu <ajuncu@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36850 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876Ab1K2BjU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 20:39:20 -0500
In-Reply-To: <4ECE31F6.4070002@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Nov 2011 14:00:54 +0200
Alex Juncu <ajuncu@ixiacom.com> wrote:

> ---
>   man/man8/ip.8 |   43 +++++++++++++++++++++++++++++++++++++++++++
>   1 files changed, 43 insertions(+), 0 deletions(-)
> 
> diff --git a/man/man8/ip.8 b/man/man8/ip.8
> index a20eca7..99c8953 100644
> --- a/man/man8/ip.8
> +++ b/man/man8/ip.8
> @@ -2855,6 +2855,49 @@ can be
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


Simple examples at bottom of page are good, but it is unnecessary
to show how to abbreviate. That just confuses the newbie reading the examples.

Give one example of each of the basic normal tasks. See the git man pages
for good examples.
