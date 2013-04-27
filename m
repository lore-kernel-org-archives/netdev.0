From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: use IANA assigned port
Date: Fri, 26 Apr 2013 23:22:32 -0400 (EDT)
Message-ID: <20130426.232232.688463657786151100.davem@davemloft.net>
References: <20130426163346.762c41c1@nehalam.linuxnetplumber.net>
	<20130426.194405.764067901709113311.davem@davemloft.net>
	<20130427015129.GJ8882@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	kduda@aristanetworks.com
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754658Ab3D0DWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 23:22:35 -0400
In-Reply-To: <20130427015129.GJ8882@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Wright <chrisw@sous-sol.org>
Date: Fri, 26 Apr 2013 18:51:29 -0700

> * David Miller (davem@davemloft.net) wrote:
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Fri, 26 Apr 2013 16:33:46 -0700
>> 
>> > Ken Duda of Arista Networks, one of the VXLAN RFC authors notified
>> > me that IANA has assigned an official port for VXLAN. My initial version
>> > of the driver used the value from CISCO LISP that was also being used by
>> > OpenVswitch.
>> > 
>> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> 
>> So how does this interact with already deployed VXLAN links?
>> 
>> What is the backwards compatability story?  What if one node upgrades
>> with this patch installed, but all the other nodes are left using
>> the older port number by default?
> 
> With this patch, I think one node upgrading would need to override
> the default vxlan_port module param (falling back to the pre IANA
> default) to keep active with the existing overlays.

That's an unacceptable burdon for our users.

We're stuck with the initial port number you've choosen.

People can override to the "official" port if they want to.
