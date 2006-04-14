From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ipw2100: wraps the debug module param within #ifdefs
Date: Fri, 14 Apr 2006 09:33:07 -0700
Message-ID: <20060414093307.3ff1c016@localhost.localdomain>
References: <20060413091423.GA28623@mail.intel.com>
	<20060413103048.64f8d0f0@localhost.localdomain>
	<1144991911.968.157.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:40107 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751267AbWDNQdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 12:33:24 -0400
To: Zhu Yi <yi.zhu@intel.com>
In-Reply-To: <1144991911.968.157.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Apr 2006 13:18:31 +0800
Zhu Yi <yi.zhu@intel.com> wrote:

> On Thu, 2006-04-13 at 10:30 -0700, Stephen Hemminger wrote:
> > Please get rid of the debug config option. Make the debug code, default
> > off and be low enough impact that everyone can ship with it.
> 
> This patch is exactly doing so. There won't be the debug module param if
> CONFIG_IPW2200_DEBUG is not defined. Otherwise it could be used to set
> different debug level, which helps a lot for the driver debuging.
> 

I meant get rid of CONFIG_IPW2200_DEBUG completely. Having the debug code isn't
bad, and there is no reason not to have it always there.
