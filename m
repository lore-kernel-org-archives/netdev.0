From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/9] xen: convert to 64 bit stats interface
Date: Thu, 09 Jun 2011 02:56:45 +0100
Message-ID: <1307584605.22348.527.camel@localhost>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.385577995@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:33077 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab1FIB4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 21:56:49 -0400
In-Reply-To: <20110609005417.385577995@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-08 at 17:53 -0700, Stephen Hemminger wrote:
> Convert xen driver to 64 bit statistics interface.
> This driver was already counting packet per queue in a 64 bit value so not
> a huge change.
[...]

I think this driver will need to use u64_stats_sync.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

