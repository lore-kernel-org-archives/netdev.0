From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: My 802.3ad is my bond
Date: Thu, 24 Jan 2008 10:06:34 +0000
Message-ID: <1201169194.22038.267.camel@quoit>
References: <1201103100.22038.254.camel@quoit>  <26889.1201108405@death>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59354 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752606AbYAXKJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 05:09:48 -0500
In-Reply-To: <26889.1201108405@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 2008-01-23 at 09:13 -0800, Jay Vosburgh wrote:
> Steven Whitehouse <swhiteho@redhat.com> wrote:
> [...]
> >This commit: ece95f7fefe3afae19e641e1b3f5e64b00d5b948 seems to have
> >caused a problem with parsing bond arguments as now only the numeric
> >arguments seem to work (in modprobe.conf) and specifying 802.3ad fails.
> >When I revert that patch in my local tree all seems ok.
> 
> 	Thanks for the report; I know what the problem here is.  I'll
> get a fix out.
> 
> >Also I notice that one of my two NICs now reports this:
> >
> >bonding: bond0: link status definitely down for interface eth0,
> >disabling it
> >bonding: bond0: Interface eth0 is already enslaved!
> >bond0.5: no IPv6 routers present
> >
> >which I think is also new with this set of bonding updates, before it
> >used to use both interfaces ok. I've not worked out which of the other
> >patches causes this so far, but I can if its helpful,
> 
> 	That would be helpful, as would some more details: e.g., the
> various options passed to bonding, the complete dmesg log, contents of
> /proc/net/bonding/bond0 [or whatever your interface is called], and
> anything else you think would be helpful.
> 
> 	-J
> 
I've been through all the patches now, reverting each in turn and it
seems that I still have the problem. Thats rather odd as I'm sure that I
didn't have only one interface working before. When I get a moment I'll
try and work out whats going on here,

Steve.


