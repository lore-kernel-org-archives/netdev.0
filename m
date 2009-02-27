From: david@lang.hm
Subject: ip_nonlocal_bind and sendto (fwd)
Date: Fri, 27 Feb 2009 01:20:07 -0800 (PST)
Message-ID: <alpine.DEB.1.10.0902270119060.7158@asgard.lang.hm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lang.hm ([64.81.33.126]:58746 "EHLO bifrost.lang.hm"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753823AbZB0JUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 04:20:09 -0500
Received: from asgard.lang.hm (asgard.lang.hm [10.0.0.100])
	by bifrost.lang.hm (8.13.4/8.13.4/Debian-3) with ESMTP id n1R9K7qE031660
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 01:20:07 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I initially sent this to lkml, but then realized I should have tried here

---------- Forwarded message ----------
Date: Fri, 27 Feb 2009 01:10:24 -0800 (PST)
From: david@lang.hm
To: linux-kernel <linux-kernel@vger.kernel.org>
Subject: ip_nonlocal_bind and sendto

I've got a need to forge the source IP of UDP packets (a stupid syslog receiver 
app that I need to deal with)

I know that this can be done with raw sockets, but with the IP_nonlocal_bind 
option I thought that it may be possible to do this without dealing with raw 
sockets

so I have an app that does the socket call, followed by the bind call without 
any errors, but when I issue the sendto call it generates error 22 (invalid 
parameter) if the source IP doesn't exist on the local box somewhere.

is this the kernel that is doing whatever check is failing? or is glibc 
wrapping the kernel syscall and doing some additional checking?

if it is the kernel that's throwing the error, is there some way of disabling 
this check? or do I have to go to raw sockets?

David Lang
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
