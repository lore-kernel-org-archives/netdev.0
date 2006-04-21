From: Andrew Athan <aathan_linux_net_1542@cloakmail.com>
Subject: Re: Cannot receive multicast packets
Date: Thu, 20 Apr 2006 20:51:25 -0400
Message-ID: <44482C8D.7010401@cloakmail.com>
References: <OF10DE8AFB.1FB28740-ON88257156.0083D32C-88257157.0000E5BE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.thinktradellc.com ([66.54.171.98]:45574 "EHLO
	mail.thinktradellc.com") by vger.kernel.org with ESMTP
	id S1751178AbWDUAv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 20:51:26 -0400
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF10DE8AFB.1FB28740-ON88257156.0083D32C-88257157.0000E5BE@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David:

Thank you for taking the time to respond.

The packets are arriving via a switched network composed of Cisco 
devices in PIM dense mode.  The packets pass through several switch 
hops, but no routing hops that have been documented to me.  I did not 
think the source IP was relevant to the matching code in linux, since 
there are no source squelching socket options.

There are no firewall rules active on this machine, and the packets are 
definitely visible at the interface (see tcpdump output in my email).

I am going to try upgrading the kernel, and turning off the multicast 
router kernel options as a next step.  But if you have any other ideas 
at all, I'm all ears.

This seems too much like Mr. Murphy's in the room.

A.

David Stevens wrote:
> I've run your test program and it receives fine for me.
>
> I note that the source address is not on the same subnet as
> (any of) the receiver's addresses. Are the packets being
> routed? The default multicasting TTL is 1, though I don't
> know if it'll be checked or dropped on the receiver, seeing
> as we aren't forwarding it.
>
> Also, you might want to run "netstat -s" to see if any of the
> drop counters are being incremented (e.g., checksum error).
>
> Finally, I'm assuming you don't have any firewall rules that
> are matching, right?
>
>                                         +-DLS
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   
