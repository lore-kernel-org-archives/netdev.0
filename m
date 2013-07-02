From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] l2tp: make datapath sequence number handling
 RFC-compliant
Date: Tue, 02 Jul 2013 16:34:42 -0700 (PDT)
Message-ID: <20130702.163442.2300932181805961904.davem@davemloft.net>
References: <1372793340-17883-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab3GBXep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 19:34:45 -0400
In-Reply-To: <1372793340-17883-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Tue,  2 Jul 2013 20:28:57 +0100

> L2TP data sequence numbers, if enabled, ensure in-order delivery. A
> receiver may reorder data packets, or simply drop out-of-sequence
> packets. If reordering is not enabled, the current implementation does
> not handle data packet loss correctly, which can result in a stalled
> L2TP session datapath as soon as the first packet is lost. Most L2TP
> users either disable sequence numbers or enable data packet reordering
> when sequence numbers are used to circumvent the issue. This patch
> series fixes the problem, and makes the L2TP sequence number handling
> RFC-compliant.
> 
> v2 incorporates string format changes requested by sergei.shtylyov@cogentembedded.com.

Series applied, thanks James.
