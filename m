From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 11/13] bnx2x: Forbid LRO on when XEN is enabled
Date: Sun, 18 Apr 2010 16:11:25 +0100
Message-ID: <1271603485.3679.210.camel@localhost>
References: <1271602258.27235.200.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	netdev list <netdev@vger.kernel.org>, dmitry@broadcom.com
To: Vladislav Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28631 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752771Ab0DRPLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 11:11:30 -0400
In-Reply-To: <1271602258.27235.200.camel@lb-tlvb-vladz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-18 at 17:50 +0300, Vladislav Zolotarov wrote:
> LRO cannot be used on virtualized environment, so it is best
> to disable it on compile time in XEN kernel.
[...]

If you want to cripple your performance, I'm not going to stand in your
way, but be aware that most distribution kernels now enable CONFIG_XEN.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

