From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Do not implement ethtool get_link() if link
 state is unknown
Date: Tue, 03 Nov 2009 02:04:44 -0800 (PST)
Message-ID: <20091103.020444.120631587.davem@davemloft.net>
References: <200911022201.30950.david-b@pacbell.net>
	<20091103.010129.100672838.davem@davemloft.net>
	<200911030141.27905.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, greg@kroah.com, jacmet@sunsite.dk,
	steve.glendinning@smsc.com, netdev@vger.kernel.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751073AbZKCKET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 05:04:19 -0500
In-Reply-To: <200911030141.27905.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Tue, 3 Nov 2009 02:41:27 -0700

> On Tuesday 03 November 2009, David Miller wrote:
>> All kidding aside, I think the alternative is for the USB network
>> driver to call ethtool_op_get_link() if it cannot determine the
>> link state in hardware.
> 
> There's usbnet_get_link() which does just that.  But
> there may be some ancient debris confusing things.

It's perfect, and Ben's patch is completely unnecessary.

