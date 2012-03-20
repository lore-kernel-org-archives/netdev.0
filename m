From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 20 Mar 2012 16:00:23 +0100
Message-ID: <20120320160023.621e948a@pluto.restena.lu>
References: <20120320134107.6acea83c@pluto.restena.lu>
	<20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.restena.lu ([158.64.1.62]:56997 "EHLO
	smtprelay.restena.lu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab2CTPAZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 11:00:25 -0400
In-Reply-To: <20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Mar 2012 07:41:40 Stephen Hemminger wrote:
> > Should this get fixed at kernel level, iproute2 libnetlink level or
> > at end-user level (e.g. collectd)?
> > Three lines every 10 seconds is a damn lot!
> > 
> > Thanks,
> > Bruno
> 
> Netlink is supposed to be encoded as Type-Length-Value and correctly written
> programs ignore types they don't understand. So either the library is getting
> confused by the type or the attribute is not encoded correctly.
> 
> 
> The issue could be in libnetlink library. What version of collectd and libnetlink
> are you using?

I've used collectd-5.0.x and collectd-4.10.3 with 3.3 kernels.
The stub code I listed is what collectd's netlink plugin does with
libnetlink (processing of netlink reply factored out for short-ness)

In all cases, linked against libnetlink from iproute2-2.6.38 (on
Gentoo)


>From looking at git history of both collectd and iproute2, on both
sides there has not been any changes that would affect the result.

Collectd:
  http://git.verplant.org/?p=collectd.git;a=history;f=src/netlink.c;hb=HEAD


Bruno
