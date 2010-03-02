From: David Miller <davem@davemloft.net>
Subject: Re: NETIF_F_FRAGLIST and NETIF_F_SG difference
Date: Mon, 01 Mar 2010 17:40:24 -0800 (PST)
Message-ID: <20100301.174024.214216263.davem@davemloft.net>
References: <de0a9dcb1003010302p2f81aa17ubdbb29bb007d50cf@mail.gmail.com>
	<1267448321.2819.15.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mekaviraj@gmail.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34223
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752225Ab0CBBkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 20:40:07 -0500
In-Reply-To: <1267448321.2819.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 01 Mar 2010 12:58:41 +0000

> (I don't know why there are two ways of adding extra data.  The latter
> does not seem to be used often.)

It's the most efficient way to handle IPv4/IPv6 fragmentation and
reassembly.
