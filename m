From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: Fix tx checksum offload for small packets
Date: Thu, 18 Mar 2010 22:19:29 -0700 (PDT)
Message-ID: <20100318.221929.68116570.davem@davemloft.net>
References: <1268940010-19394-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48156
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751339Ab0CSFTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:19:07 -0400
In-Reply-To: <1268940010-19394-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 18 Mar 2010 19:20:10 +0000

> TX checksum offload does not work properly when transmitting
> UDP packets with 0, 1 or 2 bytes of data.  This patch works
> around the problem by calculating checksums for these packets
> in the driver.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, but I had to fix up trailing whitespace on one of the
patch's lines.  Please check for and fix up such trivial matters
before I ever have to see the patch in the future, thanks.
