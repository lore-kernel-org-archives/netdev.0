From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: smsc95xx: fix mtu
Date: Thu, 26 Apr 2012 05:38:50 -0400 (EDT)
Message-ID: <20120426.053850.929602823670004153.davem@davemloft.net>
References: <1335430964-1018-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fillods@users.sf.net
To: steve.glendinning@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58405 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972Ab2DZJjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:39:03 -0400
In-Reply-To: <1335430964-1018-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is already in the 'net' tree for nearly a week:

commit 9bbf56609d304e8aae2076610d938206453035de
Author: Stephane Fillod <fillods@users.sf.net>
Date:   Fri Apr 20 09:39:23 2012 +0000

    net: usb: smsc95xx: fix mtu
    
    Make smsc95xx recalculate the hard_mtu after adjusting the
    hard_header_len.
    
    Without this, usbnet adjusts the MTU down to 1488 bytes, and the host is
    unable to receive standard 1500-byte frames from the device.
    
    Inspired by same fix on cdc_eem 78fb72f7936c01d5b426c03a691eca082b03f2b9.
    
    Tested on ARM/Beagle.
    
    Signed-off-by: Stephane Fillod <fillods@users.sf.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>
