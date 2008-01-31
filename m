From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: should explicitely initialize atomic_t field in struct
 dst_ops
Date: Wed, 30 Jan 2008 20:08:12 -0800 (PST)
Message-ID: <20080130.200812.193719610.davem@davemloft.net>
References: <20080124161117.5727c45c.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754756AbYAaEHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 23:07:52 -0500
In-Reply-To: <20080124161117.5727c45c.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 24 Jan 2008 16:11:17 +0100

> All but one struct dst_ops static initializations miss explicit
> initialization of entries field.
> 
> As this field is atomic_t, we should use ATOMIC_INIT(0), and not
> rely on atomic_t implementation.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
