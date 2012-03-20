From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 20 Mar 2012 07:41:40 -0700
Message-ID: <20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
References: <20120320134107.6acea83c@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>
To: Bruno =?ISO-8859-1?B?UHLpbW9udA==?= <bonbons@linux-vserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36759 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760259Ab2CTOlo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 10:41:44 -0400
In-Reply-To: <20120320134107.6acea83c@pluto.restena.lu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> 
> Should this get fixed at kernel level, iproute2 libnetlink level or
> at end-user level (e.g. collectd)?
> Three lines every 10 seconds is a damn lot!
> 
> Thanks,
> Bruno

Netlink is supposed to be encoded as Type-Length-Value and correctly written
programs ignore types they don't understand. So either the library is getting
confused by the type or the attribute is not encoded correctly.


The issue could be in libnetlink library. What version of collectd and libnetlink
are you using?
