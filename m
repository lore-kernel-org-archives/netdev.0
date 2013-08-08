From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] net/usb: rtl8150: allocate URB transfer_buffer and
 setup_packet separately
Date: Thu, 8 Aug 2013 18:14:10 +0300 (EEST)
Message-ID: <alpine.DEB.2.10.1308081809120.4258@fry.nucleusys.com>
References: <20130807133653.15587.35442.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:40143 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757899Ab3HHPjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 11:39:23 -0400
In-Reply-To: <20130807133653.15587.35442.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Aug 2013, Jussi Kivilinna wrote:

> rtl8150 allocates URB transfer_buffer and setup_packet as part of same 
> structure 'struct async_req'. This can cause same cacheline to be 
> DMA-mapped twice with same URB. This can lead to memory corruption on 
> some systems.

I can see performance impact due to the double mapping.  However, memory 
corruption seems a bit too much for sane cache and DMA controllers.  Out 
of interest - which is the architecture that will potentially corrupt the 
memory.


cheers,
Petko
