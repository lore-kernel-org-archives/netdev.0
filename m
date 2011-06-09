From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/9] veth: convert to 64 bit statistics
Date: Thu, 09 Jun 2011 03:00:41 +0100
Message-ID: <1307584841.22348.528.camel@localhost>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.449670103@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33236 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1FICAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 22:00:45 -0400
In-Reply-To: <20110609005417.449670103@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-08 at 17:53 -0700, Stephen Hemminger wrote:
> Not much change, device was already keeping per cpu statistics.
> Use recent 64 statistics interface.
[...]

It's also going to need to use u64_stats_sync functions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

