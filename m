From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] forcedeth: Addition of new device id
Date: Wed, 03 Jun 2009 14:26:47 -0700 (PDT)
Message-ID: <20090603.142647.149845259.davem@davemloft.net>
References: <4A257B1A.8080205@nvidia.com>
	<20090603132509.d3121eff.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aabdulla@nvidia.com, manfred@colorfullife.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753607AbZFCV0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:26:46 -0400
In-Reply-To: <20090603132509.d3121eff.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 3 Jun 2009 13:25:09 -0700

> On Tue, 02 Jun 2009 15:18:50 -0400
> Ayaz Abdulla <aabdulla@nvidia.com> wrote:
> 
>> This patch adds support for new ethernet device in the MCP89 chipset.
>> 
>> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
>> 
> 
> It's best to combine these two patches into one, IMO.

Andrew, we do not add new entries to pci_ids.h any more.

Just use the constant directly when using it in the driver
ID table.
