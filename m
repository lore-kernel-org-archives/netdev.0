From: David Hollis <dhollis@davehollis.com>
Subject: Re: FC5 iptables-restore failure
Date: Thu, 15 Feb 2007 09:04:23 -0500
Message-ID: <1171548263.3873.1.camel@dhollis-lnx.sunera.com>
References: <20070215024507.8c97ee01.akpm@linux-foundation.org>
	<20070215112022.GD8353@redhat.com>
	<20070215041041.69e20c64.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:12520 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932777AbXBOOE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Feb 2007 09:04:57 -0500
Received: from smtp.davehollis.com ([72.64.146.108])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JDI004M8CG843R1@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Thu, 15 Feb 2007 08:04:56 -0600 (CST)
In-reply-to: <20070215041041.69e20c64.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-02-15 at 04:10 -0800, Andrew Morton wrote:
> On Thu, 15 Feb 2007 06:20:22 -0500 Dave Jones <davej@redhat.com> wrote:
> 
> > On Thu, Feb 15, 2007 at 02:45:07AM -0800, Andrew Morton wrote:
> >  > 
> >  > I've recently been noticing nasty messages come out of FC5:
> >  > 
> >  > sony:/home/akpm# service iptables stop
> >  > Flushing firewall rules:                                   [  OK  ]
> >  > Setting chains to policy ACCEPT: filter                    [  OK  ]
> >  > Unloading iptables modules:                                [  OK  ]
> >  > sony:/home/akpm# service iptables start
> >  > Applying iptables firewall rules: iptables-restore: line 20 failed
> >  >                                                            [FAILED]
> >  > 
> >  > Dunno when it started happening, but it's in mainline now.
> >  > 
> >  > It's a pretty stupid error message.  line 20 of what?
> > 
> > 2.6.18 -> 2.6.19 changes a bunch of netfilter config option names.
> > Sure you weren't bitten by that ?
> 
> Yeah, going and madly turning 1000 things on seemed to make it happy.

If you ran system-config-securitylevel to do that, that probably made it
re-generate the /etc/sysconfig/iptables file which is dumped to
iptables.  

-- 
David Hollis <dhollis@davehollis.com>

