From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Wed, 30 Jun 2010 13:58:16 -0700 (PDT)
Message-ID: <20100630.135816.106800276.davem@davemloft.net>
References: <20100611084854.0680c014@nehalam>
	<20100622.101537.245382806.davem@davemloft.net>
	<20100630135535.0e3a5ea1@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joakim.tjernlund@transmode.se, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755243Ab0F3U6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 16:58:03 -0400
In-Reply-To: <20100630135535.0e3a5ea1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 30 Jun 2010 13:55:35 -0700

>> The fact that the syctl knob, when enabled, can't even function properly
>> in this "multiple interfaces with same address" case is another reason I
>> have decided to not apply this.
> 
> We already have sysctl knobs that exist to work around broken printer TCP,
> middleboxes and other broken stacks; my opinion this is just another one
> of those types of workarounds.

But that sysctl knob for the printer workaround doesn't break legitimate
configurations like this one does.
