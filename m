From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6] de2104x: use speed defines instead of
 number
Date: Wed, 01 Jun 2011 18:26:34 +0100
Message-ID: <1306949194.2758.1.camel@bwh-desktop>
References: <1306937677-11101-1-git-send-email-jpirko@redhat.com>
	 <1306943206.22348.10.camel@localhost>
	 <20110601161932.GA2784@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26556 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155Ab1FAR0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 13:26:37 -0400
In-Reply-To: <20110601161932.GA2784@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-01 at 18:19 +0200, Jiri Pirko wrote:
> Wed, Jun 01, 2011 at 05:46:46PM CEST, bhutchings@solarflare.com wrote:
> >The speed/speed_hi fields are defined to hold speed in Mbit/s, not only
> >specific values.  I don't see any reason to use the names any more.
> 
> Do you mean to remove SPEED_X defines in whole code?
[...]

I have higher priorities - but I would happy to see someone do that.
The definitions have to stay in <linux/ethtool.h> for user space,
though.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

