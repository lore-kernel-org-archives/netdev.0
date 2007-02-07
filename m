From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3 : avoid an expensive divide
Date: Wed, 07 Feb 2007 01:45:14 -0800 (PST)
Message-ID: <20070207.014514.132928442.davem@davemloft.net>
References: <45C8EAC4.9020803@cosmosbay.com>
	<20070206.131908.13769204.davem@davemloft.net>
	<p73ireemgwm.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, mchan@broadcom.com, netdev@vger.kernel.org
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43566
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161086AbXBGJpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 04:45:15 -0500
In-Reply-To: <p73ireemgwm.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: 07 Feb 2007 10:54:49 +0100

> Probably Eric compiled with the now default CONFIG_CC_OPTIMIZE_FOR_SIZE/-Os.
> With that gcc decides to use the shorter hardware divide instruction, even
> though it is significantly slower than an expanded optimized sequence
> for constant dividend.
> 
> We've seen this in a few other cases while during performance regression
> testing between kernels that still used -O2 vs the newer -Os.
> 
> No good solution found unfortunately.

Thanks for the explanation, that makes a lot of sense.
