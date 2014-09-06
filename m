From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] Series short description
Date: Fri, 05 Sep 2014 17:44:16 -0700 (PDT)
Message-ID: <20140905.174416.696225755473441828.davem@davemloft.net>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	willemb@google.com
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaIFAoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:44:17 -0400
In-Reply-To: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 04 Sep 2014 13:30:29 -0400

> This change makes it so that the core path for the phy timestamping logic
> is shared between skb_tx_tstamp and skb_complete_tx_timestamp.  In addition
> it provides a means of using the same skb clone type path in non phy
> timestamping drivers.
> 
> The main motivation for this is to enable non-phy drivers to be able to
> manipulate tx timestamp skbs for such things as putting them in lists or
> setting aside buffer in the context block.

Series applied, thanks.
