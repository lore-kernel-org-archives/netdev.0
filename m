From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] ipw2100: wraps the debug module param within #ifdefs
Date: Mon, 17 Apr 2006 10:17:43 +0800
Message-ID: <1145240263.968.203.camel@debian.sh.intel.com>
References: <20060413091423.GA28623@mail.intel.com>
	 <20060413103048.64f8d0f0@localhost.localdomain>
	 <1144991911.968.157.camel@debian.sh.intel.com>
	 <20060414093307.3ff1c016@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:58845 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750966AbWDQCZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 22:25:07 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060414093307.3ff1c016@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-14 at 09:33 -0700, Stephen Hemminger wrote:
> I meant get rid of CONFIG_IPW2200_DEBUG completely. Having the debug code isn't
> bad, and there is no reason not to have it always there.

There are lots of IPW_DEBUG_XXX in the driver, even in TX and RX paths.
It cause extra cycles for those who really don't need it.

Thanks,
-yi

