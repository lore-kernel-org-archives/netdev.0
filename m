From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vxlan: use IANA assigned port
Date: Fri, 26 Apr 2013 19:44:05 -0400 (EDT)
Message-ID: <20130426.194405.764067901709113311.davem@davemloft.net>
References: <20130426163346.762c41c1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kduda@aristanetworks.com,
	chrisw@sous-sol.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46688 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755890Ab3DZXoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 19:44:07 -0400
In-Reply-To: <20130426163346.762c41c1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 26 Apr 2013 16:33:46 -0700

> Ken Duda of Arista Networks, one of the VXLAN RFC authors notified
> me that IANA has assigned an official port for VXLAN. My initial version
> of the driver used the value from CISCO LISP that was also being used by
> OpenVswitch.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

So how does this interact with already deployed VXLAN links?

What is the backwards compatability story?  What if one node upgrades
with this patch installed, but all the other nodes are left using
the older port number by default?
