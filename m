From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] Avoid two divides in __tcp_grow_window()
Date: Fri, 21 Dec 2007 06:08:32 -0800 (PST)
Message-ID: <20071221.060832.260127595.davem@davemloft.net>
References: <20071221150551.dccfe24f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753089AbXLUOIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:08:32 -0500
In-Reply-To: <20071221150551.dccfe24f.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 21 Dec 2007 15:05:51 +0100

> tcp_win_from_space() being signed, compiler might emit an integer divide
> to compute tcp_win_from_space()/2 .
> 
> Using right shifts is OK here and less expensive.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
