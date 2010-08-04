From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] iproute2:  Allow 'ip addr flush' to loop more than
 10 times.
Date: Wed, 4 Aug 2010 14:00:12 -0700
Message-ID: <20100804140012.577b2195@nehalam>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: greearb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41920 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758992Ab0HDVAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 17:00:17 -0400
In-Reply-To: <1277790959-28075-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jun 2010 22:55:59 -0700
greearb@gmail.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> The default remains at 10 for backwards compatibility.
> 
> For instance:
>  # ip addr flush dev eth2
>  *** Flush remains incomplete after 10 rounds. ***
>  # ip -l 20 addr flush dev eth2
>  *** Flush remains incomplete after 20 rounds. ***
>  # ip -loops 0 addr flush dev eth2
>  #
> 
> This is useful for getting rid of large numbers of IP
> addresses in scripts.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

The current userspace driven flush behavior is crap.
There really should be an atomic flush netlink message
with kernel support.
