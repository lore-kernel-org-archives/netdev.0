From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ipw2100: wraps the debug module param within #ifdefs
Date: Mon, 17 Apr 2006 09:24:45 -0700
Message-ID: <20060417092445.22952efa@localhost.localdomain>
References: <20060413091423.GA28623@mail.intel.com>
	<20060413103048.64f8d0f0@localhost.localdomain>
	<1144991911.968.157.camel@debian.sh.intel.com>
	<20060414093307.3ff1c016@localhost.localdomain>
	<1145240263.968.203.camel@debian.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24515 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751142AbWDQQYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 12:24:54 -0400
To: Zhu Yi <yi.zhu@intel.com>
In-Reply-To: <1145240263.968.203.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006 10:17:43 +0800
Zhu Yi <yi.zhu@intel.com> wrote:

> On Fri, 2006-04-14 at 09:33 -0700, Stephen Hemminger wrote:
> > I meant get rid of CONFIG_IPW2200_DEBUG completely. Having the debug code isn't
> > bad, and there is no reason not to have it always there.
> 
> There are lots of IPW_DEBUG_XXX in the driver, even in TX and RX paths.
> It cause extra cycles for those who really don't need it.
> 
> Thanks,
> -yi

IMHO. There is never a reason for a driver specific config option for debugging.
Either it the debug option is generally useful for support (ie distro's will want it on),
in which case the debugging should be runtime settable but always available;
or the debug option is so meant for the driver developers in which case it should
be enabled by a source modification (see #define DEBUG and pr_debug).

But, those are opinions only and certainly, you can do what you want with your
driver.
