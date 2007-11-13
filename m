From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Problems with ULI 526x driver
Date: Tue, 13 Nov 2007 23:50:25 +0100
Message-ID: <20071113225025.GA19060@electric-eye.fr.zoreil.com>
References: <47389E72.7050907@freescale.com> <4738A7A4.1030004@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peerchen@gmail.com, netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57208 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754996AbXKMWzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 17:55:37 -0500
Content-Disposition: inline
In-Reply-To: <4738A7A4.1030004@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi <timur@freescale.com> :
[...]
> Update: I can ping anything on my subnet, but nothing else.  Also, it looks 
> like my MAC address is hosed:
[...]
> It turns out that the driver is getting the MAC address from the ID table:
> 
> 	if(((u16 *) db->srom)[0] == 0xffff || ((u16 *) db->srom)[0] == 0) /* 
> 	SROM absent, so read MAC address from ID Table */
> 	{
> 
> 
> In my case, the address that is returned is all zeros.  I don't know 
> anything about the ULI 526x hardware.  Is it possible that there's a 
> missing EEPROM on my board that's supposed to hold the MAC address?  Are 
> these registers user-writable?

You previously said that the tulip driver + reverted change works with
your card (TULIP_MMIO was not set, right ?). I guess it did correctly set
the HW address, did it not ?

-- 
Ueimor
