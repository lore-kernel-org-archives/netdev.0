From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: Fix warnings due to -Wunused-but-set-variable.
Date: Tue, 12 Apr 2011 11:21:14 -0700 (PDT)
Message-ID: <20110412.112114.104057205.davem@davemloft.net>
References: <20110411.160143.258100330.davem@davemloft.net>
	<20110412160002.GB1433@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932335Ab1DLSVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 14:21:52 -0400
In-Reply-To: <20110412160002.GB1433@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Tue, 12 Apr 2011 11:00:04 -0500

> On Mon, Apr 11, 2011 at 04:01:43PM -0700, David Miller wrote:
>> 
>> Most of these are cases where we are trying to read back a register
>> after a write to ensure completion.
>> 
>> Simply pre-fixing the readl() or readq() with "(void)" is sufficient
>> because these are volatile operations and the compiler cannot eliminate
>> them just because no real assignment takes place.
>> 
>> The case of free_rxd_blk()'s assignments to "struct buffAdd *ba" is a
>> real spurious assignment as this variable is completely otherwise
>> unused.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> Acked-by: Jon Mason <jdmason@kudzu.us>

Thanks for reviewing.
