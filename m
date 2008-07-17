From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 17 Jul 2008 13:31:17 +0400
Message-ID: <20080717093117.GA8373@martell.zuzino.mipt.ru>
References: <12162854952457-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, yjwei@cn.fujitsu.com, rdreier@cisco.com,
	shemminger@vyatta.com, davem@davemloft.net, jcliburn@gmail.com,
	parag.warudkar@gmail.com, w@1wt.eu,
	oliver.schuster@schweigstill.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:28125 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbYGQJeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 05:34:03 -0400
Received: by ug-out-1314.google.com with SMTP id h2so626277ugf.16
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 02:34:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <12162854952457-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Full patch for the Atheros L1E Gigabit Ethernet driver.
> Supportring AR8121, AR8113 and AR8114

Does it have the same 4G limitation as ATL1 card?

If yes, pci_using_64 logic isn't needed, and copying comment from atl1 driver wouldn't hurt,
If no, you're setting small DMA mask.

