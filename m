From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: mark BIC as experimental
Date: Fri, 31 Oct 2008 12:04:24 -0700 (PDT)
Message-ID: <20081031.120424.30521138.davem@davemloft.net>
References: <20081030083641.55e936b0@extreme>
	<20081031.005033.172610018.davem@davemloft.net>
	<20081031094113.2bab9140@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751689AbYJaTEt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 15:04:49 -0400
In-Reply-To: <20081031094113.2bab9140@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 31 Oct 2008 09:41:13 -0700

> On Fri, 31 Oct 2008 00:50:33 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Thu, 30 Oct 2008 08:36:41 -0700
> > 
> > > Change the configuration defaults to mark BIC as experimental.
> > > BIC is too aggressive and was replaced by CUBIC. Debian was picking
> > > BIC in their default config (should be fixed by now), but the configuration
> > > documentation did not make it explicit that this was a bad idea.
> > > 
> > > Also update the URLs in the configuration documentation to current
> > > locations.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > I understand your intention, but I'm not so sure we should do this.
> > 
> > It's more than a double standard to make this change, yet still
> > allow things like HTCP to still be a default.
> > 
> > And you can't even make this selection without asking for
> > TCP_CONG_ADVANCED.   Well... duh!
> 
> Some architectures were setting TCP_CONG_ADVANCED and choosing BIC

I'm sure you can find a pile of other nonsense settings in the arch
defconfigs if you keep looking.  And those should be similarly fixed,
but in the arch defconfigs.

But that has no bearing on what we're discussing here.
