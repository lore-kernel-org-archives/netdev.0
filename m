From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Tue, 06 May 2014 16:53:47 -0400 (EDT)
Message-ID: <20140506.165347.1104086045678188867.davem@davemloft.net>
References: <1399315907-27148-1-git-send-email-nhorman@tuxdriver.com>
	<alpine.LNX.2.03.1405070152550.22076@ws.cisco>
	<20140506205046.GC2858@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, netdev@vger.kernel.org, cooldavid@cooldavid.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287AbaEFUxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 16:53:49 -0400
In-Reply-To: <20140506205046.GC2858@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 6 May 2014 16:50:46 -0400

>> >+		ctxbi = txbi + ((startidx + j + 2) & (mask));
>> >+		pci_unmap_page(jme->pdev,
>> >+				ctxbi->mapping,
>> >+				ctxbi->len,
>> >+				PCI_DMA_TODEVICE);
>> >+
>> >+				ctxbi->mapping = 0;
>> >+				ctxbi->len = 0;
>> 
>> Alignment, a tab from 'for'
> Not sure what you mean by this, I don't see any alignment errors above, or in my
> tree.  Checkpatch also claims its clean.

Indeed it is indented correctly, the "+" at the beginning of the line in
the patch makes it look like it's not, but it is.
