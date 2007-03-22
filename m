From: David Miller <davem@davemloft.net>
Subject: Re: many sockets, slow sendto
Date: Wed, 21 Mar 2007 18:15:10 -0700 (PDT)
Message-ID: <20070321.181510.104045031.davem@davemloft.net>
References: <4600592E.80605@fw.hu>
	<460064C6.5030302@cosmosbay.com>
	<4601ADD8.8040500@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zacco@fw.hu, baruch@ev-en.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38528
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933196AbXCVBPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 21:15:10 -0400
In-Reply-To: <4601ADD8.8040500@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 21 Mar 2007 23:12:40 +0100

> I chose in this patch to hash UDP sockets with a hash function that take into 
> account both their port number and address : This has a drawback because we 
> need two lookups : one with a given address, one with a wildcard (null) address.

Thanks for doing this work Eric, I'll review this when I get home
tomorrow night or Friday.
