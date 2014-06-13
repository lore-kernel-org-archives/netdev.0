From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Checksum fixes
Date: Fri, 13 Jun 2014 13:27:01 -0700 (PDT)
Message-ID: <20140613.132701.1226816839536831499.davem@davemloft.net>
References: <alpine.DEB.2.02.1406121554310.30089@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60468 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751811AbaFMU1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2014 16:27:04 -0400
In-Reply-To: <alpine.DEB.2.02.1406121554310.30089@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 12 Jun 2014 16:02:52 -0700 (PDT)

> Fixes related to some recent checksum modifications.
> 
> - Fix logic in saving checksums complete in __skb_checksum_complete
> - Call __skb_checksum_complete from UDP if we are checksumming over
>   whole packet in order to save checksum.
> - Fixes to VXLAN to work correctly with checksum complete

I figure this series will need to be respun after you figure out the
problems Geert is still seeing with the full series applied.
