From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Mon, 2 Jun 2008 11:41:16 -0400
Message-ID: <20080602114116.1c1a5efd.billfink@mindspring.com>
References: <20080531195702.0b879dd1.billfink@mindspring.com>
	<20080601014620.GG30769@solarflare.com>
	<20080601164614.012fe1f6.billfink@mindspring.com>
	<20080601.223938.193701581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, alan@lxorguk.ukuu.org.uk, jimi@sngx.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:48483 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbYFBPlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 11:41:32 -0400
In-Reply-To: <20080601.223938.193701581.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 01 Jun 2008, David Miller wrote:

> From: Bill Fink <billfink@mindspring.com>
> Date: Sun, 1 Jun 2008 16:46:14 -0400
> 
> > Another issue that occurred to me is if multiple people are working
> > on troubleshooting a network problem, how do we insure that they all
> > get a consistent view of the stats?
> 
> Some of them definitely won't get a consistent view if one of them
> triggers this undesirable statistic clearing knob.

The typical case I was referring to is for example when I am assisting
someone else with troubleshooting.  This is coordinated with the system
admin, who would usually be the one to clear/snapshot the stats.  This
cannot be done by a normal user as it requires root privileges.  BTW
I'm also not clear why running "ethtool -S" requires root privileges,
as it would be more convenient if a normal user could do this (currently
I have to be given sudo access).

This is a useful mechanism for many, many people.  Bottom line I don't
really care if it's done in the kernel or in user space, but it should
be possible using the standard "ethtool -S" command, and I have raised
at least a couple of issues with modifying the ethtool command to
support this (but which wouldn't be an issue if implemented in the
kernel).

						-Bill
