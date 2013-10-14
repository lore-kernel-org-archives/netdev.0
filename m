From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] ixgbe: enable l2 forwarding acceleration for macvlans
Date: Mon, 14 Oct 2013 06:50:23 -0400
Message-ID: <20131014105023.GC26880@hmsreliant.think-freely.org>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com>
 <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com>
 <1381517037-26007-3-git-send-email-nhorman@tuxdriver.com>
 <525B0721.7060709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49955 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652Ab3JNKu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 06:50:27 -0400
Content-Disposition: inline
In-Reply-To: <525B0721.7060709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 01:48:33PM -0700, John Fastabend wrote:
> On 10/11/2013 11:43 AM, Neil Horman wrote:
> >Now that l2 acceleration ops are in place from the prior patch, enable ixgbe to
> >take advantage of these operations.  Allow it to allocate queues for a macvlan
> >so that when we transmit a frame, we can do the switching in hardware inside the
> >ixgbe card, rather than in software.
> >
> >Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >CC: john.fastabend@gmail.com
> >CC: Andy Gospodarek <andy@greyhouse.net>
> >CC: "David S. Miller" <davem@davemloft.net>
> >---
> 
> Neil, I'm fairly sure I can simplify this patch further. I'll be able
> to take a shot at it Tuesday if you don't mind waiting.
> 
> I can resubmit the series then and preserve your signed-off on at least
> the first patch. Seem reasonable?
> 
That sounds fine.
Thanks!
Neil

> .John
> 
> -- 
> John Fastabend         Intel Corporation
> 
