From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: fix regression from
 6509141f9c2ba74df6cc72ec35cd1865276ae3a4
Date: Fri, 08 Feb 2013 01:52:45 -0500 (EST)
Message-ID: <20130208.015245.1813436587925276241.davem@davemloft.net>
References: <1360289919-20409-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cpuwolf@gmail.com
To: dev@lynxeye.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57610 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab3BHGwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 01:52:46 -0500
In-Reply-To: <1360289919-20409-1-git-send-email-dev@lynxeye.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Stach <dev@lynxeye.de>
Date: Fri,  8 Feb 2013 03:18:39 +0100

> The newly added flag NOARP was using an already defined value, which
> broke drivers using flag MULTI_PACKET.
> 
> Signed-off-by: Lucas Stach <dev@lynxeye.de>

Applied, but I reworked your commit message like so:

    net: usb: fix regression from FLAG_NOARP code
    
    In commit 6509141f9c2ba74df6cc72ec35cd1865276ae3a4 ("usbnet: add new
    flag FLAG_NOARP for usb net devices"), the newly added flag NOARP was
    using an already defined value, which broke drivers using flag
    MULTI_PACKET.
    
    Signed-off-by: Lucas Stach <dev@lynxeye.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>

References to commit IDs are ambiguous because a change can go
into multiple GIT trees.  Therefore we don't reference them in
commit header lines, and when we reference them in the commit
body we postfix them with the commit header line of the
referenced commit (in parenthesis and quotes) in order to
eliminate the ambiguity.

Thanks.
