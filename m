From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: send Change Status Report after DAD is completed
Date: Fri, 17 Jan 2014 17:02:02 +0100
Message-ID: <20140117160202.GD26022@order.stressinduktion.org>
References: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45856 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbaAQQCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 11:02:04 -0500
Content-Disposition: inline
In-Reply-To: <1389907679-15346-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 07:27:59PM -0200, Flavio Leitner wrote:
> The RFC 3810 defines two type of messages for multicast
> listeners. The "Current State Report" message, as the name
> implies, refreshes the *current* state to the querier.
> Since the querier sends Query messages periodically, there
> is no need to retransmit the report.
> 
> On the other hand, any change should be reported immediately
> using "State Change Report" messages. Since it's an event
> triggered by a change and that it can be affected by packet
> loss, the rfc states it should be retransmitted [RobVar] times
> to make sure routers will receive timely.
> 
> Currently, we are sending "Current State Reports" after
> DAD is completed.  Before that, we send messages using
> unspecified address (::) which should be silently discarded
> by routers.
> 
> This patch changes to send "State Change Report" messages
> after DAD is completed fixing the behavior to be RFC compliant
> and also to pass TAHI IPv6 testsuite.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

I don't see any obvious problems and looks spec conformant, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
