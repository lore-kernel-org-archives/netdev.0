From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: mii-tool gigabit support.
Date: Fri, 29 Sep 2006 10:12:15 -0700
Message-ID: <20060929101215.649a9e32@freekitty>
References: <20060926145113.7a6791c8@freekitty>
	<4519A1D6.1050802@pobox.com>
	<Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>
	<451AD1D6.4030708@intel.com>
	<1159546378.2761.5.camel@dhollis-lnx.sunera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, dean gaudet <dean@arctic.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44759 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422640AbWI2RPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 13:15:05 -0400
To: David Hollis <dhollis@davehollis.com>
In-Reply-To: <1159546378.2761.5.camel@dhollis-lnx.sunera.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006 12:12:58 -0400
David Hollis <dhollis@davehollis.com> wrote:

> On Wed, 2006-09-27 at 12:32 -0700, Auke Kok wrote:
> > dumping registers in readable format is an extension that needs to be 
> > implemented per driver. Not all nics have done this - we just did it
> > ourselves 
> > for ixgb, and I saw skge/sky2 just fly by this week. 
> 
> This has always bothered me a bit with ethtool.  It really stinks that
> we have to actually write code and generate patches and get everyone to
> update a utility just to be able to get this type of access.  I see two
> ways to make the situation better:  1) add extensions to the drivers
> themselves to be able to report this which would likely lead to a lot of
> driver bloat and too much user-space style info (like verbose
> descriptions of the register and it's purpose) or 2) develop some style
> of register description definition type of text file, maybe XML, maybe
> INI style or something stored in /etc/ethtool as <drivername>.conf or
> something like that.  This way, ethtool doesn't have to be
> changed/updated/patched/likely-bug-added for every single device known
> to man.  
> 
> Just a thought.
 
We could switch to shared libraries like 'tc' uses.


-- 
Stephen Hemminger <shemminger@osdl.org>
