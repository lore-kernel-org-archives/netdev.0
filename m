From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: revisit IEEE 802 local multicast groups
Date: Fri, 1 Jul 2011 09:26:12 -0700
Message-ID: <20110701092612.07b045bf@nehalam.ftrdhcpuser.net>
References: <1309518770-8547-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nick Carter <ncarter100@gmail.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46874 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757164Ab1GAQ1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 12:27:44 -0400
In-Reply-To: <1309518770-8547-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  1 Jul 2011 13:12:50 +0200
David Lamparter <equinox@diac24.net> wrote:

> this first and foremost fixes handling of bonding frames, which were
> incorrectly forwarded until now. they need to never cross a bridge.
> 
> it also introduces a new switch to control handling of the other
> not-that-special groups; if you want them forwarded despite having
> STP running, there's a sysfs knob for that. you can implement your
> local policy with ebtables then.
> 
> in the end, we now match hardware switch behaviour rather closely, but
> still additionally allow playing tricks on things like 802.1X.
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Nick Carter <ncarter100@gmail.com>

Forwarding pause frames is wrong.

I wonder if the best solution for this crap is to just write
a userland program to do the forwarding.
