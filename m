From: Alex Dubov <oakad@yahoo.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Sun, 9 Jan 2011 22:33:40 -0800 (PST)
Message-ID: <373539.88491.qm@web37603.mail.mud.yahoo.com>
References: <20110109195711.1d622b2e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37603.mail.mud.yahoo.com ([209.191.87.86]:24928 "HELO
	web37603.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751418Ab1AJGdn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 01:33:43 -0500
In-Reply-To: <20110109195711.1d622b2e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Any ideas where this particular problem may
> originate?
> 
> Is there a bug in checksum offload in the driver?
> Does the hardware correctly handle checksum of packets that
> are
> unaligned or whose length is an odd number of bytes?
> 
> If the hardware can't do checksum correctly, the driver
> should either
> disable checksum offload or in worst case copy the packet
> to a new
> buffer that is in a known safe place.

I managed to work around the issue by clearing the NETIF_F_IP_CSUM
feature flag of the gianfar network driver, so it appears the bug is
indeed somewhere there.



      
