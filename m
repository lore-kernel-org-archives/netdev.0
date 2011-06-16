From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 8/24] bnx2x: dump FW memory when appropriate
 msglvl is raised
Date: Thu, 16 Jun 2011 22:08:53 +0100
Message-ID: <1308258533.2925.12.camel@bwh-desktop>
References: <201106141433.25717.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Vlad Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24140 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030191Ab1FPVI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 17:08:57 -0400
In-Reply-To: <201106141433.25717.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware dump functionality should be connected up to the new
ethtool operations added by:

commit 29dd54b72ba8c5ad0dd6dd33584449b5953f700b
Author: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date:   Thu May 12 12:48:32 2011 +0000

    ethtool: Added support for FW dump

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

