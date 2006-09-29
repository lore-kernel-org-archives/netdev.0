From: David Hollis <dhollis@davehollis.com>
Subject: Re: mii-tool gigabit support.
Date: Fri, 29 Sep 2006 12:12:58 -0400
Message-ID: <1159546378.2761.5.camel@dhollis-lnx.sunera.com>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>
	<Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>
	<451AD1D6.4030708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dean gaudet <dean@arctic.org>, Jeff Garzik <jgarzik@pobox.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:58044 "EHLO
	vms046pub.verizon.net") by vger.kernel.org with ESMTP
	id S932318AbWI2QOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:14:31 -0400
Received: from smtp.davehollis.com ([72.64.146.245])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0J6D008693S1L3W2@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 29 Sep 2006 11:14:26 -0500 (CDT)
In-reply-to: <451AD1D6.4030708@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 12:32 -0700, Auke Kok wrote:
> dumping registers in readable format is an extension that needs to be 
> implemented per driver. Not all nics have done this - we just did it
> ourselves 
> for ixgb, and I saw skge/sky2 just fly by this week. 

This has always bothered me a bit with ethtool.  It really stinks that
we have to actually write code and generate patches and get everyone to
update a utility just to be able to get this type of access.  I see two
ways to make the situation better:  1) add extensions to the drivers
themselves to be able to report this which would likely lead to a lot of
driver bloat and too much user-space style info (like verbose
descriptions of the register and it's purpose) or 2) develop some style
of register description definition type of text file, maybe XML, maybe
INI style or something stored in /etc/ethtool as <drivername>.conf or
something like that.  This way, ethtool doesn't have to be
changed/updated/patched/likely-bug-added for every single device known
to man.  

Just a thought.

-- 
David Hollis <dhollis@davehollis.com>

