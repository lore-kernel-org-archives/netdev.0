From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: mark BIC as experimental
Date: Fri, 31 Oct 2008 00:50:33 -0700 (PDT)
Message-ID: <20081031.005033.172610018.davem@davemloft.net>
References: <006001c93a0d$477d4e30$4a580e98@ncsu2cc0c3fa00>
	<20081030083641.55e936b0@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58012
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751419AbYJaHu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:50:58 -0400
In-Reply-To: <20081030083641.55e936b0@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 30 Oct 2008 08:36:41 -0700

> Change the configuration defaults to mark BIC as experimental.
> BIC is too aggressive and was replaced by CUBIC. Debian was picking
> BIC in their default config (should be fixed by now), but the configuration
> documentation did not make it explicit that this was a bad idea.
> 
> Also update the URLs in the configuration documentation to current
> locations.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I understand your intention, but I'm not so sure we should do this.

It's more than a double standard to make this change, yet still
allow things like HTCP to still be a default.

And you can't even make this selection without asking for
TCP_CONG_ADVANCED.   Well... duh!
