From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: AF_BUS socket address family
Date: Fri, 29 Jun 2012 12:16:39 -0600
Message-ID: <4FEDF107.8030700@genband.com>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og118.obsmtp.com ([64.18.2.8]:49172 "EHLO
	exprod7og118.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2F2SSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 14:18:35 -0400
In-Reply-To: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2012 10:45 AM, Vincent Sanders wrote:
> This series adds the bus address family (AF_BUS) it is against
> net-next as of yesterday.
>
> AF_BUS is a message oriented inter process communication system.
>
> The principle features are:
>
>   - Reliable datagram based communication (all sockets are of type
>     SOCK_SEQPACKET)
>
>   - Multicast message delivery (one to many, unicast as a subset)
>
>   - Strict ordering (messages are delivered to every client in the same order)
>
>   - Ability to pass file descriptors
>
>   - Ability to pass credentials
>

I haven't had time to look at the code yet, but if you haven't already 
I'd like to propose adding the ability for someone with suitable 
privileges to eavesdrop on all communications.  We've been using 
something similar to this (essentially a simplified multicast unix 
datagram protocol) for many years now and having a tcpdump-like ability 
is very useful for debugging.

Chris
