From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Mon, 09 Apr 2007 11:14:52 -0700
Message-ID: <461A829C.7050703@candelatech.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>	 <20070406133420.2f098bc6@localhost>	 <m1ps6g5229.fsf@ebiederm.dsl.xmission.com> <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:49025 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752820AbXDISQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 14:16:29 -0400
In-Reply-To: <461A70A5.8060607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:

> It would be nice if someone would finally come up with a generic
> interface based on netlink (RTM_NEWLINK) instead of adding yet
> another couple of homegrown interfaces.

My preference is for ioctls, procfs, or similar that does not
require extra libraries.  Ethtool is an ioctl based approach,
so that could potentially be used, though I'm not sure if
that's the right place to put it...

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

