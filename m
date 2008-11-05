From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] loopback: optimization
Date: Wed, 05 Nov 2008 01:49:18 -0800 (PST)
Message-ID: <20081105.014918.151015047.davem@davemloft.net>
References: <20081103213758.59a8361d@extreme>
	<490FED80.9090601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48003
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbYKEJtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:49:43 -0500
In-Reply-To: <490FED80.9090601@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 04 Nov 2008 07:36:48 +0100

> So are you sure you use the right one (&lo->napi, not &pcpu->napi) ?

Yes I think this logic error in Stephen's patch might
explain why it had no effect.

Stephen please try with lo->napi replaced with pcpu->napi
here.
