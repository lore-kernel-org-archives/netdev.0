From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Fri, 26 Feb 2010 19:51:04 +0300
Message-ID: <20100226165104.GB5364@lenovo>
References: <20090511114639.440944109@openvz.org> <20090519152153.012d4814@nehalam> <20090520192726.GF4968@lenovo> <20090520131225.03b7715a@nehalam> <20090521180805.GC4932@lenovo> <20090521140504.1865883b@nehalam> <20090522201850.GF5354@lenovo> <20100226081843.07f37742@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org,
	Pavel Emelyanov <xemul@openvz.org>,
	Denis Lunev <den@openvz.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:40909 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965375Ab0BZQvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 11:51:10 -0500
Received: by fxm19 with SMTP id 19so289843fxm.21
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2010 08:51:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100226081843.07f37742@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2010 at 08:18:43AM -0800, Stephen Hemminger wrote:
> Looking back at this. What if the API was simpler:
> 
> Instead of:
> > Typical session looks like
> > 
> > | s...@10.10.0.160$ brctl addbr br0
> > | s...@10.10.0.160$ ifconfig br0 up
> > | s...@10.10.0.160$ echo 1 > /sys/class/net/bridge/br0/via_phys_dev
> > | s...@10.10.0.160$ brctl addif br0 eth0
> > | (...waiting a bit...)
> > | s...@10.10.0.160$
> 
> Why not:
>   1. Setup bridge (and any other interfaces except eth0); includes bringing br0 up
>   2. Add eth0 to bridge with new flag to inherit
>        a. brctl addif br0 eth0 inherit
> 
> Inherit functionality would need to move address (Ether, IP, IPv6)
> and routes from eth0 to br0.
> I will see about doing it as much as possible in userspace.
> 

Looks promising for me (CC'ed a few people just to be sure I'm not
missing anything).

	-- Cyrill
