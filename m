From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: ax88796: avoid 64 bit arithmetic
Date: Fri, 19 Apr 2013 20:46:09 +0200
Message-ID: <201304192046.09566.arnd@arndb.de>
References: <201304191506.21220.arnd@arndb.de> <20130419.133603.1487086024178553164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@fluff.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:61247 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab3DSSqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:46:25 -0400
In-Reply-To: <20130419.133603.1487086024178553164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 19 April 2013, David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Fri, 19 Apr 2013 15:06:21 +0200
> 
> > When building ax88796 on an ARM platform with 64-bit resource_size_t,
> > we currently get
> > 
> > drivers/net/ethernet/8390/ax88796.c:875: undefined reference to `__aeabi_uldivmod'
> > 
> > because we do a division on the length of the MMIO resource.
> > Since we know that this resource is very short, using an
> > "unsigned long" instead of "resource_size_t" is entirely
> > sufficient, and avoids this link-time error.
> 
> Please provide a proper signoff with your patches, thanks.

Sorry about this, I have no idea how this slipped through. I'll
send a new version right away.

	Arnd
