From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/9] veth: convert to 64 bit statistics
Date: Wed, 8 Jun 2011 20:22:33 -0700
Message-ID: <20110608202241.52ce68ae@nehalam.ftrdhcpuser.net>
References: <20110609005356.160260858@vyatta.com>
	<20110609005417.449670103@vyatta.com>
	<1307584841.22348.528.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60936 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755025Ab1FIDWq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 23:22:46 -0400
In-Reply-To: <1307584841.22348.528.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 09 Jun 2011 03:00:41 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Wed, 2011-06-08 at 17:53 -0700, Stephen Hemminger wrote:
> > Not much change, device was already keeping per cpu statistics.
> > Use recent 64 statistics interface.
> [...]
> 
> It's also going to need to use u64_stats_sync functions.
> 
> Ben.
> 

No veth is doing per-cpu update therefore the new code has the same guarantee
as the old code.
