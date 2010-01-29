From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: Bug fix to support newer generation of BE ASIC
Date: Thu, 28 Jan 2010 23:03:59 -0800 (PST)
Message-ID: <20100128.230359.112600771.davem@davemloft.net>
References: <20100128075633.GA4785@serverengines.com>
	<1264718429.373.520.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ajitk@serverengines.com, netdev@vger.kernel.org, stable@kernel.org,
	stable-review@kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752540Ab0A2HEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 02:04:15 -0500
In-Reply-To: <1264718429.373.520.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 28 Jan 2010 22:40:29 +0000

> On Thu, 2010-01-28 at 13:26 +0530, Ajit Khaparde wrote:
>> Bug fix in be2net for newer generation of BladeEngine ASIC.
> [...]
>> @@ -2162,6 +2168,7 @@ static int be_stats_init(struct be_adapter *adapter)
>>  	cmd->va = pci_alloc_consistent(adapter->pdev, cmd->size, &cmd->dma);
>>  	if (cmd->va == NULL)
>>  		return -1;
>> +	memset(cmd->va, cmd->size, 0);
>>  	return 0;
>>  }
>>  
> [...]
> 
> I don't think this does what you think it does.

I'll fix this.
