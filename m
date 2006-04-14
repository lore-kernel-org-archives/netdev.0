From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] ipw2100: wraps the debug module param within #ifdefs
Date: Fri, 14 Apr 2006 13:18:31 +0800
Message-ID: <1144991911.968.157.camel@debian.sh.intel.com>
References: <20060413091423.GA28623@mail.intel.com>
	 <20060413103048.64f8d0f0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:63930 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S965105AbWDNFZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 01:25:52 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060413103048.64f8d0f0@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-04-13 at 10:30 -0700, Stephen Hemminger wrote:
> Please get rid of the debug config option. Make the debug code, default
> off and be low enough impact that everyone can ship with it.

This patch is exactly doing so. There won't be the debug module param if
CONFIG_IPW2200_DEBUG is not defined. Otherwise it could be used to set
different debug level, which helps a lot for the driver debuging.

Thanks,
-yi

