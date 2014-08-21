From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Thu, 21 Aug 2014 19:32:11 +0200
Message-ID: <1408642331.4388.2.camel@jlt4.sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 (sfid-20140821_192515_304437_37E734D5)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:37675 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818AbaHUReM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Aug 2014 13:34:12 -0400
In-Reply-To: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net> (sfid-20140821_192515_304437_37E734D5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-21 at 19:22 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> RFC 1122 says that unicast packets encapsulated in broadcast
> link-layer packets should be dropped. Implement that, but also
> extend it to link-layer multicast packets.

I cannot find anything equivalent in the IPv6 RFCs - anyone more
familiar with that who could help check for that?

And if it's *not* in the IPv6 RFCs, how should we implement this?

johannes
