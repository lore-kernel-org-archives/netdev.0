From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH net-next-2.6 2/2] jme: Cleanup PM operations after using new PM API
Date: Tue, 28 Jun 2011 19:19:31 +0800
Message-ID: <20110628111732.M60965@cooldavid.org>
References: <1309238615-25590-1-git-send-email-cooldavid@cooldavid.org> <1309238615-25590-2-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=utf-8
Cc: "linux-netdev" <netdev@vger.kernel.org>,
	"Aries Lee" <arieslee@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>
To: "Guo-Fu Tseng" <cooldavid@cooldavid.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:42495 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702Ab1F1LTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 07:19:33 -0400
In-Reply-To: <1309238615-25590-2-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2011 13:23:35 +0800, Guo-Fu Tseng wrote
> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> 	1. Using enum name instead of numeric value.
> 	2. device_set_wakeup_enable expect bool argument
> 	   adding !!() to the argument to be passed.
> 	3. Remove non-hardware related operations from
> 	   jme_clear_pm()
> 	4. Reuse jme_clear_pm() in jme_resume()
> 	5. Clear wakeup event indicator bits(call jme_clear_pm())
> 	   before going to sleep.
> 	6. Check for wakeup setting while shutdown
> 		Turn off PHY if wakeup is not enabled.
> 		Power-safe PHY(lower speed) if wakeup is enabled.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
Dear Davem:

Please ignore this patch.
I'll resend a cleaner version later.

Sorry for the inconvenience.

Guo-Fu Tseng

