From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Do not implement ethtool get_link() if link
 state is unknown
Date: Wed, 04 Nov 2009 00:36:05 -0800 (PST)
Message-ID: <20091104.003605.202776578.davem@davemloft.net>
References: <200911030141.27905.david-b@pacbell.net>
	<20091103.020444.120631587.davem@davemloft.net>
	<1257304800.3136.452.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, greg@kroah.com, jacmet@sunsite.dk,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750906AbZKDIfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 03:35:40 -0500
In-Reply-To: <1257304800.3136.452.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 04 Nov 2009 03:20:00 +0000

> I don't see how it's 'perfect' since it reports the link as up where it
> is really unknown.  Still, this is a fairly minor bug.

That is the policy we enforce for all drivers, especially virtual
ones.  If you can't tell, you specify that the link is up.

Otherwise automated tools like NetworkManager et al. will not even
attempt to bring do DHCP and bring the network device online.
