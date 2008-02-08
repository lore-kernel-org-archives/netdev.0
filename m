From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET] ROUTE: remove unecessary alignment
Date: Thu, 07 Feb 2008 23:30:15 -0800 (PST)
Message-ID: <20080207.233015.127191948.davem@davemloft.net>
References: <47AC02E2.1070506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49372
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934216AbYBHH3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 02:29:45 -0500
In-Reply-To: <47AC02E2.1070506@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 08 Feb 2008 08:21:06 +0100

> Same alignment requirement was removed on IP route cache in the past.
> 
> This alignment actually has bad effect on 32 bit arches, uniprocessor, since
> sizeof(dn_rt_hash_bucket) is forced to 8 bytes instead of 4.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, anyone who shows love for DecNET deserves some love
in return :-)
