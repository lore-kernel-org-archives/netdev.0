From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 21 Jan 2010 17:50:02 +0100
Message-ID: <4B5885BA.7090007@s5r6.in-berlin.de>
References: <20100118212516.GE3157@del.dom.local>	<4B54D50C.90608@majjas.com>	<20100118220814.GG3157@del.dom.local>	<20100118221747.GH3157@del.dom.local>	<4B54E4EF.8080602@majjas.com>	<4B554730.6090000@majjas.com>	<20100119104739.GA9088@ff.dom.local>	<4B55D40F.5080509@majjas.com>	<20100119195933.GA3060@del.dom.local>	<4B5610A9.7030902@majjas.com>	<20100119224508.GA3473@del.dom.local>	<4B5655D6.8090503@majjas.com> <20100119171013.207cac5c@nehalam> <4B587D4D.2010300@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:39975 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650Ab0AUQvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 11:51:50 -0500
In-Reply-To: <4B587D4D.2010300@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter wrote:
> I didn't read the start of this thread and may misunderstand the issue,
> but I comment anyway...:
> 
> Documentation/DMA-API.txt says the following about (pci_)dma_sync_single
> and friends:  "All the parameters must be the same as those passed into
> the single mapping API."
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/DMA-API.txt;h=5aceb88b3f8b622c8c23ed288f37f42de705c904;hb=HEAD#l367
> 
> So, it might be considered an API bug --- but it is a documented one. :-)

Disregard my comment.  I just noticed that there is more qualified
discussion of this in the thread "[PATCH] sky2: Fix WARNING: at
lib/dma-debug.c:902 check_sync".
-- 
Stefan Richter
-=====-==-=- ---= =-=-=
http://arcgraph.de/sr/
