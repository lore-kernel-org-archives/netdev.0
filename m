From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: Fix incorrect disable_ipv6 behavior
Date: Fri, 13 Mar 2009 20:52:40 -0400
Message-ID: <49BAFFD8.7030705@hp.com>
References: <> <1236292120-32050-1-git-send-email-brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:11760 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762971AbZCNAwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 20:52:43 -0400
In-Reply-To: <1236292120-32050-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> Fix the behavior of allowing both sysctl and addrconf_dad_failure()
> to set the disable_ipv6 parameter without any bad side-effects.
> If DAD fails and accept_dad > 1, we will still set disable_ipv6=1,
> but then instead of allowing an RA to add an address then
> immediately fail DAD, we simply don't allow the address to be
> added in the first place.  This also lets the user set this flag
> and disable all IPv6 addresses on the interface, or on the entire
> system.

So I haven't seen an Ack/Nack for this patch, and the patchwork queue has shrunk
to just a handful in the past few hours :)

-Brian
