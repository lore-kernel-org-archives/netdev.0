From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Wed, 12 Aug 2009 12:02:04 -0700
Message-ID: <20090812120204.2e13163e@nehalam>
References: <bb6e06c00908121150q6d08cdfdp818c26cd8ae4f064@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Slot <slot.daniel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32915 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269AbZHLTCL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 15:02:11 -0400
In-Reply-To: <bb6e06c00908121150q6d08cdfdp818c26cd8ae4f064@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Aug 2009 20:50:59 +0200
Daniel Slot <slot.daniel@gmail.com> wrote:

> RFC 4653 specifies Non-Congestion Robustness (NCR) for TCP.
> In the absence of explicit congestion notification from the network,
> TCP uses loss as an indication of congestion.
> One of the ways TCP detects loss is using the arrival of three
> duplicate acknowledgments.
> However, this heuristic is not always correct, notably in the case
> when network paths reorder segments (for whatever reason), resulting
> in degraded performance.
> TCP-NCR is designed to mitigate this degraded performance by
> increasing the number of duplicate acknowledgments required to trigger
> loss recovery,
> based on the current state of the connection, in an effort to better
> disambiguate true segment loss from segment reordering.
> This document specifies the changes to TCP, as well as the costs and
> benefits of these modifications.
> 
> This patch adds TCP-NCR as socket option to the Linux kernel (version 2.6.30.4).
> Written by Daniel Slot, Email: slot.daniel(at)gmail.com

Patch has funny indentation and awkward naming for socket elements.
Your style needs to match existing code.

What is the usage model for this? I expect that some user who wants
to enable this would be stuck somewhere with a lossy network and
would want to enable it. Or is it something only researchers will
want to play with?

It would be easier to use a sysctl value for this because otherwise
each application has to be changed to select the socket option.

-- 
