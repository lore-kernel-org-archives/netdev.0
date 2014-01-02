From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch iproute2 v2 0/2] add support for IFA_F_MANAGETEMPADDR
Date: Thu, 2 Jan 2014 18:29:49 +0100
Message-ID: <20140102172949.GF22494@order.stressinduktion.org>
References: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	thaller@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35582 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbaABR3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 12:29:50 -0500
Content-Disposition: inline
In-Reply-To: <1388676879-2603-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 02, 2014 at 04:34:37PM +0100, Jiri Pirko wrote:
> v1->v2: Removed 0xff masking of ifa_flags
> 
> Jiri Pirko (2):
>   add support for extended ifa_flags
>   add support for IFA_F_MANAGETEMPADDR
> 
>  include/linux/if_addr.h |  2 ++
>  ip/ipaddress.c          | 50 +++++++++++++++++++++++++++++++++++--------------
>  2 files changed, 38 insertions(+), 14 deletions(-)

I still wonder how source address selection should work for
IFA_F_MANAGETEMPADDR if use_tempaddr != 2 mode is not available for
those addresses.

Up until now applications can bind to those addresses and traffic can be
received for them, but there is now way how a user can specify to favor them
in case of use_tempaddr == 0.

Greetings,

  Hannes
