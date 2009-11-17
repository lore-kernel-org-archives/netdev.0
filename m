From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: Fixing EEH handler to handle more than one error
Date: Mon, 16 Nov 2009 23:52:09 -0800 (PST)
Message-ID: <20091116.235209.227827212.davem@davemloft.net>
References: <1257878267-7489-1-git-send-email-leitao@linux.vnet.ibm.com>
	<20091115.221628.243358818.davem@davemloft.net>
	<Pine.WNT.4.64.0911161100030.16132@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754053AbZKQHvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 02:51:53 -0500
In-Reply-To: <Pine.WNT.4.64.0911161100030.16132@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 16 Nov 2009 11:01:13 -0800 (Pacific Standard Time)

> On Sun, 15 Nov 2009, David Miller wrote:
> 
>> From: leitao@linux.vnet.ibm.com
>> Date: Tue, 10 Nov 2009 13:37:47 -0500
>> 
>> > After commmit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff EEH breaks
>> > after the second error, since it calls pci_restore_state()
>> > but it returns 0, since pci->state_saved is false.
>> > 
>> > So, this patch just call pci_save_state() after pci_restore_state().
>> > 
>> > Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
>> 
>> Intel folks, are you integrating or looking at this patch?
> 
> This patch looks correct and makes sense to me.  I'm going to ACK it now, 
> but we'll still pull it in and test it.  If we see any issues, we'll 
> report them with possible fixes.  But at this point, I think this patch is 
> fine.
> 
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied, thanks.
