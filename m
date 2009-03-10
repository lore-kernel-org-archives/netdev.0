From: David Miller <davem@davemloft.net>
Subject: Re: XFRM state hash value
Date: Tue, 10 Mar 2009 07:18:41 -0700 (PDT)
Message-ID: <20090310.071841.10239678.davem@davemloft.net>
References: <49B636DB.7010004@dev.6wind.com>
	<20090310.042051.107256879.davem@davemloft.net>
	<49B67450.1060002@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751666AbZCJOSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 10:18:55 -0400
In-Reply-To: <49B67450.1060002@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Tue, 10 Mar 2009 15:08:16 +0100

> This patch is ok with my test case.
> I'm asking me if we should perform the step with saddr_wildcard if we have already found one. The state with a src address may have an higher priority than the state with a wildcare address, no?

Good point, I'll think about the semantics and update my patch
as necessary.
