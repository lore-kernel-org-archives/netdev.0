From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2 0/2] sctp: Add Auto-ASCONF support
Date: Thu, 07 Apr 2011 20:33:52 -0700 (PDT)
Message-ID: <20110407.203352.183049674.davem@davemloft.net>
References: <BC3A4B88-4312-4371-9209-39666C698F60@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: micchie@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47453
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757407Ab1DHDe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 23:34:29 -0400
In-Reply-To: <BC3A4B88-4312-4371-9209-39666C698F60@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Thu, 7 Apr 2011 18:08:15 +0900

> SCTP reconfigure the IP addresses in the association by using ASCONF chunks as mentioned in RFC5061.  
> For example, we can start to use the newly configured IP address in the existing association.  
> ASCONF operation is invoked in two ways: 
> First is done by the application to call sctp_bindx() system call.  
> Second is automatic operation in the SCTP stack with address events in the host computer (called auto_asconf) .  
> The former is already implemented, but the latter is not yet. This patch enables it with one sysctl parameter and setsockopt() system call.  
> (This patch is a part of larger patch that supports complete auto_asconf)
> 
> Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>

This is a very confusing patch submission.

The "0/N" posting should not itself contain a patch, it should merely be
a posting that provides only a top-level description of the patches
that appear in subsequent "1/N", "2/N", etc. postings.

I'm not even going to try and figure out how these patches are really
supposed to be ordered or be applied, and instead ask you to resubmit
this properly.

Thank you.
