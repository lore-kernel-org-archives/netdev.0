From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] r8169: revert part of	6dccd16b7c2703e8bbf8bca62b5cf248332afbe2
Date: Fri, 05 Oct 2007 14:05:19 -0400
Message-ID: <47067CDF.8020709@garzik.org>
References: <20071003224250.GA22366@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeti@welho.com,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?6Kix5oGG5ZiJ?= <edward_hsu@realtek.com.tw>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33729 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbXJESFX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 14:05:23 -0400
In-Reply-To: <20071003224250.GA22366@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> The 8169/8110SC currently announces itself as:
> [...]
> eth0: RTL8169sc/8110sc at 0x........, ..:..:..:..:..:.., XID 18000000 IRQ ..
>                                                              ^^^^^^^^
> It uses RTL_GIGA_MAC_VER_05 and this part of the changeset can cut
> its performance by a factor of 2~2.5 as reported by Timo.
> 
> (the driver includes code just before the hunk to write the ChipCmd
> register when mac_version == RTL_GIGA_MAC_VER_0[1-4])
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Timo Jantunen <jeti@welho.com>

I'm applying this, but, please do copy Edward @ RealTek on patches like 
this, as a courtesy if nothing else.

Sometimes the kernel development process can be a bit impenetrable for 
newcomers, and I'd like to give as much visibility as possible to the 
process for the hardware vendor.

	Jeff



