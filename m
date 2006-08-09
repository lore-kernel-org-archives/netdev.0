From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
Date: Wed, 09 Aug 2006 02:30:03 -0400
Message-ID: <44D980EB.5010608@garzik.org>
References: <20060808193447.1396.59301.sendpatchset@lappy>	<44D9191E.7080203@garzik.org>	<44D977D8.5070306@google.com> <20060808.225537.112622421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: phillips@google.com, a.p.zijlstra@chello.nl,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50594 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030546AbWHIGaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 02:30:09 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.225537.112622421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Daniel Phillips <phillips@google.com>
> Date: Tue, 08 Aug 2006 22:51:20 -0700
> 
>> Elaborate please.  Do you think that all drivers should be updated to
>> fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
>> If so, I trust you will help audit for it?
> 
> I think he's saying that he doesn't think your code is yet a
> reasonable way to solve the problem, and therefore doesn't belong
> upstream.

Pretty much.  It is completely non-sensical to add NETIF_F_MEMALLOC, 
when it should be blindingly obvious that every net driver will be 
allocating memory, and every net driver could potentially be used with 
NBD and similar situations.

	Jeff


