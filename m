From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: mii-tool gigabit support.
Date: Sun, 01 Oct 2006 18:31:27 +0400
Message-ID: <451FD13F.2020707@tls.msk.ru>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com>	<Pine.LNX.4.64.0609271215150.2299@twinlark.arctic.org>	<451AD1D6.4030708@intel.com>	<1159546378.2761.5.camel@dhollis-lnx.sunera.com> <20060929101215.649a9e32@freekitty> <451D5DEE.2080609@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	David Hollis <dhollis@davehollis.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	dean gaudet <dean@arctic.org>, Jeff Garzik <jgarzik@pobox.com>,
	dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:18766 "EHLO hobbit.corpit.ru")
	by vger.kernel.org with ESMTP id S1751491AbWJAObi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2006 10:31:38 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <451D5DEE.2080609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> 2) develop some style
>>> of register description definition type of text file, maybe XML, maybe
>>> INI style or something stored in /etc/ethtool as <drivername>.conf or
>>> something like that.  This way, ethtool doesn't have to be
>>> changed/updated/patched/likely-bug-added for every single device known
>>> to man. 
>>> Just a thought.
>>  
>> We could switch to shared libraries like 'tc' uses.
> 
> From a practical standpoint is shipping a new config file or a new
> shared library all that much different from a new ethtool binary?

New config - certainly yes.  After all, it's trivial to change a line
in a config file locally.  But yes, new shared lib is the same as a
new binary.

. o O { /sys/class/net/$iface/config.xml }    ;)

But seriously, I don't think it's that a bad idea.  Maybe not xml,
but a plain list of registers with their names - a static string
known to each driver isn't much a bloat really.  I think anyway.

/mjt
