From: David Miller <davem@davemloft.net>
Subject: Re: [patch] usbnet: pegasus: endian bug in write_mii_word()
Date: Fri, 03 May 2013 16:12:16 -0400 (EDT)
Message-ID: <20130503.161216.182244575049778035.davem@davemloft.net>
References: <20130503064420.GA14069@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan@nucleusys.com, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933810Ab3ECUMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:12:18 -0400
In-Reply-To: <20130503064420.GA14069@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 3 May 2013 09:44:20 +0300

> We're only passing the two high bits of an integer.  It works for little
> endian but not for big endian.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

s/bits/bytes/, applied, and queued up for stable, thanks
