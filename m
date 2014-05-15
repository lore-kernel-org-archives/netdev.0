From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] Altera TSE: Fix Sparse errors and misc
 issues
Date: Thu, 15 May 2014 16:47:14 -0400 (EDT)
Message-ID: <20140515.164714.1967120681951985023.davem@davemloft.net>
References: <1400096317-4969-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbaEOUrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 16:47:16 -0400
In-Reply-To: <1400096317-4969-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Wed, 14 May 2014 14:38:35 -0500

> This is version 2 of a patch series to correct sparse errors, cppcheck
> warnings, and workaound a multicast filtering issue in the Altera TSE
> Ethernet driver. Multicast filtering is not working as expected, so if
> present in the hardware will not be used and promiscuous mode enabled
> instead. This workaround will be replaced with a working solution when
> completely debugged, integrated and tested. 
> 
> Version 2 is different from the first submission by breaking out the 
> workaround as a seperate patch and addressing a few structure instance
> declarations by making them const per review comments. 
> 
> If you find this patch acceptable, please consider this for inclusion into
> the Altera TSE driver source code. 

Series applied to 'net', thanks.
