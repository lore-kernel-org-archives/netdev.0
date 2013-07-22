From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Mon, 22 Jul 2013 22:09:09 +0100
Message-ID: <1374527349.1635.55.camel@bwh-desktop.uk.level5networks.com>
References: <51ED998D.7000300@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54831 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904Ab3GVVJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 17:09:13 -0400
In-Reply-To: <51ED998D.7000300@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 21:43 +0100, William Manley wrote:
> If an IGMP join packet is lost you will not receive data sent to the 
> multicast group so if no data arrives from that multicast group in a 
> period of time after the IGMP join a second IGMP join will be sent.  The 
> delay between joins is the "IGMP Unsolicited Report Interval".
> 
> In the kernel this seems to be hard coded to be chosen randomly between 
> 0-10s.  In our use-case (IPTV) this is too long as it can cause channel 
> change to be slow in the presence of packet loss.
> 
> I would guess that this 10s has come from IGMPv2 RFC2236, which was 
> reduced to 1s in IGMPv3 RFC3376.
> 
> There was a thread about this on linux-rdma in 2010 in the context of IP 
> over Infiniband but it seems no patches got applied as a result of the 
> discussion:
> 
> http://www.mail-archive.com/linux-rdma@vger.kernel.org/msg05740.html
> 
> Would the right patch reducing the unsolicited report interval for 
> IGMPv3 be acceptable now?

I suggest you post a patch and find out what people think of it.  That
usually gets more response than asking in the abstract.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
