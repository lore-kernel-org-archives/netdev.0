From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Avoid divides in net/core/gen_estimator.c
Date: Thu, 03 Jan 2008 20:40:11 -0800 (PST)
Message-ID: <20080103.204011.267068504.davem@davemloft.net>
References: <20080103141235.dbff886f.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753724AbYADEkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 23:40:11 -0500
In-Reply-To: <20080103141235.dbff886f.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 3 Jan 2008 14:12:35 +0100

> We can void divides (as seen with CONFIG_CC_OPTIMIZE_FOR_SIZE=y on x86)
> changing ((HZ<<idx)/4) to ((HZ/4) << idx)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
