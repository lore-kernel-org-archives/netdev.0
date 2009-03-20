From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: fix big endian rx checksum offload
Date: Fri, 20 Mar 2009 01:15:26 -0700 (PDT)
Message-ID: <20090320.011526.32032988.davem@davemloft.net>
References: <1237461152-5519-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754608AbZCTIPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:15:39 -0400
In-Reply-To: <1237461152-5519-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 19 Mar 2009 11:12:32 +0000

> The cpu_to_le16 here looks suspicious to me, I don't think we need it
> because put_unaligned_le16 also does this.
> 
> I don't currently have any big endian hardware with a PCI bus available
> to test on, so I haven't been able to verify this.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Looks good, applied.

skb->csum is never unaligned so you probably want to also
convert this to use one of the aligned endianness store
interfaces.
