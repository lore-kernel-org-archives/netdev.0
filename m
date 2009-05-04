From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix tcp_prequeue() to get correct rto_min value
Date: Mon, 04 May 2009 11:11:09 -0700 (PDT)
Message-ID: <20090504.111109.22323090.davem@davemloft.net>
References: <20090503003547.GA14015@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: satoru.satoh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756557AbZEDSLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 14:11:14 -0400
In-Reply-To: <20090503003547.GA14015@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Satoru SATOH <satoru.satoh@gmail.com>
Date: Sun, 3 May 2009 09:35:47 +0900

> tcp_prequeue() refers to the constant value (TCP_RTO_MIN) regardless of
> the actual value might be tuned. The following patches fix this and make
> tcp_prequeue get the actual value returns from tcp_rto_min().
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

Applied, thanks.
