From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 18:58:13 +0200
Message-ID: <461A70A5.8060607@trash.net>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>	 <20070406133420.2f098bc6@localhost>	 <m1ps6g5229.fsf@ebiederm.dsl.xmission.com> <1176136628.8459.34.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40270 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753737AbXDIQ6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 12:58:22 -0400
In-Reply-To: <1176136628.8459.34.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Fri, 2007-04-06 at 20:51 -0600, Eric W. Biederman wrote:
> 
> 
>>The only sysfs attributes that were always available that I could find
>>were module parameters.  A little odd because we can specify them on
>>the kernel command line, or when loading the module in addition to
>>being available at run time.  
>>
>>It gives me a general interface that is usable so long as the module
>>is loaded, and does not depend on the availability of any specific
>>network device.  I will happily use any other interface that gives
>>me the same level of functionality for the roughly the same level
>>of effort.
> 
> 
> Just for consideration, in wireless we currently create virtual network
> devices by having a "add_iface" and "remove_iface" sysfs files below the
> ieee80211 class.


It would be nice if someone would finally come up with a generic
interface based on netlink (RTM_NEWLINK) instead of adding yet
another couple of homegrown interfaces.

