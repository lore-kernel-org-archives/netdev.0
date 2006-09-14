From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets,  but not icmp
Date: Thu, 14 Sep 2006 10:56:19 +0200
Message-ID: <20060914085618.GA4623@outpost.ds9a.nl>
References: <20060913112307.GA1374@outpost.ds9a.nl> <45085185.2060904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cpw@lanl.gov, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost.ds9a.nl ([213.244.168.210]:27113 "EHLO outpost.ds9a.nl")
	by vger.kernel.org with ESMTP id S1751484AbWINI4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 04:56:46 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45085185.2060904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 13, 2006 at 08:44:21PM +0200, Patrick McHardy wrote:

> Are you using TSO on the outgoing device? If so please try to log the
> packet using iptables to see if it really is a TSO packet.

Good catch! I turned off TSO and things are working fine again.

Is this a known problem, should it be documented or fixed? I'm more than
willing to write up some warnings should this be a good idea.

Thanks Patrick! I can do without TSO but not without mmapped pcap!

	Bert


-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://netherlabs.nl              Open and Closed source services
