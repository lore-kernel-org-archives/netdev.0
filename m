From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: Fix DMA unmap warning
Date: Tue, 06 May 2014 17:10:28 -0400 (EDT)
Message-ID: <20140506.171028.1170337163654829281.davem@davemloft.net>
References: <20140506205046.GC2858@hmsreliant.think-freely.org>
	<20140506.165347.1104086045678188867.davem@davemloft.net>
	<alpine.LNX.2.03.1405070230210.1428@ws.cisco>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	cooldavid@cooldavid.org
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbaEFVKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 17:10:30 -0400
In-Reply-To: <alpine.LNX.2.03.1405070230210.1428@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Wed, 7 May 2014 02:34:55 +0530 (IST)

> 
> 
> On Tue, 6 May 2014, David Miller wrote:
> 
>> From: Neil Horman <nhorman@tuxdriver.com>
>> Date: Tue, 6 May 2014 16:50:46 -0400
>>
>>>>> +		ctxbi = txbi + ((startidx + j + 2) & (mask));
>>>>> +		pci_unmap_page(jme->pdev,
>>>>> +				ctxbi->mapping,
>>>>> +				ctxbi->len,
>>>>> +				PCI_DMA_TODEVICE);
>>>>> +
>>>>> +				ctxbi->mapping = 0;
>>>>> +				ctxbi->len = 0;
>>>>
>>>> Alignment, a tab from 'for'
>>> Not sure what you mean by this, I don't see any alignment errors
>>> above, or in my
>>> tree.  Checkpatch also claims its clean.
>>
>> Indeed it is indented correctly, the "+" at the beginning of the line
>> in
>> the patch makes it look like it's not, but it is.
>>
> 
> Hmm. This is how it looked when I applied the patch.
> http://i.imgur.com/ZdjqJ3d.png
> 
> ctxbi->mapping = 0;
> ctxbi->len = 0;
> 
> is aligned to '(' of pci_unmap_page. But these two statements are not
> arg of
> the function. Shouldn't it be aligned along pci_unmap_page and not '('

It should be aligned to the first column after the openning "(" of the
function call.
