From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: add mac_pton() for parsing MAC address
Date: Mon, 09 May 2011 12:11:07 -0700 (PDT)
Message-ID: <20110509.121107.179924768.davem@davemloft.net>
References: <20110508090007.GA5094@p183>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38388
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753947Ab1EITLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:11:39 -0400
In-Reply-To: <20110508090007.GA5094@p183>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 8 May 2011 12:00:07 +0300

> mac_pton() parses MAC address in form XX:XX:XX:XX:XX:XX and only in that form.
> 
> mac_pton() doesn't dirty result until it's sure string representation is valid.
> 
> mac_pton() doesn't care about characters _after_ last octet,
> it's up to caller to deal with it.
> 
> mac_pton() diverges from 0/-E return value convention.
> Target usage:
> 
> 	if (!mac_pton(str, whatever->mac))
> 		return -EINVAL;
> 	/* ->mac being u8 [ETH_ALEN] is filled at this point. */
> 	/* optionally check str[3 * ETH_ALEN - 1] for termination */
> 
> Use mac_pton() in pktgen and netconsole for start.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
