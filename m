From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/1] r8169: workaround for missing extended GigaMAC registers
Date: Thu, 6 Dec 2012 13:25:30 +0100
Message-ID: <20121206122530.GA3318@electric-eye.fr.zoreil.com>
References: <20121206073842.GA3847@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Lee Chun-Yi <jlee@suse.com>, Hayes Wang <hayeswang@realtek.com>
To: Wang YanQing <udknight@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46220 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754997Ab2LFMuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 07:50:44 -0500
Content-Disposition: inline
In-Reply-To: <20121206073842.GA3847@udknight>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang YanQing:
[...]
> Are you sure we will lose GigaMAC registers's content
> after NIC into PCI_D3hot state ?

I have not made such a claim.

Only some bioses f*ck things up on resume, see:

http://marc.info/?l=linux-netdev&m=132195832624117&w=2

My test computer and its 8168evl (courtesy of Realtek) was not able to make
a difference w/o the patch: it always works.

-- 
Ueimor
