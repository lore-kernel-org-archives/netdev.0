From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Using Wireless Extensions in a Kernel Module
Date: Fri, 10 Jul 2009 09:39:24 -0700
Message-ID: <1247243964.9709.71.camel@localhost.localdomain>
References: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
To: Tim Schneider <schneid5@cs.uni-bonn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53058 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725AbZGJQjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2009 12:39:20 -0400
In-Reply-To: <A353FA76-7D71-425F-BD67-FEE6DC26EF6F@cs.uni-bonn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tim,

> I am trying to write a Kernel Module with an implementation of a new  
> TCP-Algorithm. Since I need to know the RSSI-Value (Received Signal  
> Strength indication) of the sent package, I extended the Pluggable  
> Congestion Control Mechanism by a new function which is called right  
> after the package is send. At that point, I need to read the RSSI-Value.
> 
> I'm now trying to somehow access that value, but I can't figure out  
> how. I've come as far, that I found out about the Wirelless  
> Extensions, which seem to be very promising. In the header file the  
> author states, that this mechanism can be used by both user-space apps  
> and kernel modules. Unfortunately nobody seems to ever have used it in  
> kernel space, since I can't find any documentations about it.
> 
> I would be very glad, if somebody could give me link to a page  
> containing informations about this topic, or even just a hint that  
> could help me.

we are in the process of killing Wireless Extensions (WEXT) and
replacing it with a netlink based cfg80211/nl80211 interface. The better
mailing list is linux-wireless@vger.kernel.org for such questions.

Regards

Marcel


