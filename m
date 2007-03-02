From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Fri, 02 Mar 2007 10:29:53 -0800
Message-ID: <45E86D21.6080208@candelatech.com>
References: <20070301232443.195603797@goop.org> <20070301232529.648076372@goop.org> <20070301164214.4a40bc59@freekitty> <45E7764A.7000100@goop.org> <20070301173030.754514ec@freekitty> <Pine.LNX.4.64.0703021006470.27021@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:51927 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751038AbXCBS16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 13:27:58 -0500
In-Reply-To: <Pine.LNX.4.64.0703021006470.27021@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Savola wrote:
> On Thu, 1 Mar 2007, Stephen Hemminger wrote:
>> What about implementing the unused arp_announce flag on the inetdevice?
>> Something like the following.  Totally untested...
>>
>> Looks like it either was there (and got removed) or was planned but
>> never implemented.
IN_DEV_ARP_ANNOUNCE is in 2.6.18, at least..used in arp_solicit in arp.c

I really hope this didn't get removed because I find it very useful!

But, you could certainly add another sysctl...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


