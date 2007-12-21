From: David Miller <davem@davemloft.net>
Subject: Re: [INET] Avoid an integer divide in rt_garbage_collect()
Date: Fri, 21 Dec 2007 01:49:25 -0800 (PST)
Message-ID: <20071221.014925.232771542.davem@davemloft.net>
References: <476B7762.30908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754341AbXLUJt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:49:26 -0500
In-Reply-To: <476B7762.30908@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 09:20:50 +0100

> Since 'goal' is a signed int, compiler may emit an integer divide
> to compute goal/2.
> 
> Using a right shift is OK here and less expensive.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks.
