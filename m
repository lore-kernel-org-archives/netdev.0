From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: Change defaults on cookie hmac selection
Date: Sat, 15 Dec 2012 17:16:20 -0800 (PST)
Message-ID: <20121215.171620.1992551971037225064.davem@davemloft.net>
References: <1355511060-27320-1-git-send-email-nhorman@tuxdriver.com>
	<1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org,
	vyasevich@gmail.com, linux-sctp@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34283 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab2LPBQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 20:16:21 -0500
In-Reply-To: <1355534521-32719-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 14 Dec 2012 20:22:01 -0500

> Recently I posted commit 3c68198e75 which made selection of the cookie hmac
> algorithm selectable.  This is all well and good, but Linus noted that it
> changes the default config:
> http://marc.info/?l=linux-netdev&m=135536629004808&w=2
> 
> I've modified the sctp Kconfig file to reflect the recommended way of making
> this choice, using the thermal driver example specified, and brought the
> defaults back into line with the way they were prior to my origional patch
> 
> Also, on Linus' suggestion, re-adding ability to select default 'none' hmac
> algorithm, so we don't needlessly bloat the kernel by forcing a non-none
> default.  This also led me to note that we won't honor the default none
> condition properly because of how sctp_net_init is encoded.  Fix that up as
> well.
> 
> Tested by myself (allbeit fairly quickly).  All configuration combinations seems
> to work soundly.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied.
