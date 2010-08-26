From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bna: Fixed build break for allyesconfig
Date: Wed, 25 Aug 2010 23:45:19 -0700 (PDT)
Message-ID: <20100825.234519.112609091.davem@davemloft.net>
References: <201008260557.o7Q5v8AU028127@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amathur@brocade.com, ddutt@brocade.com,
	huangj@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751859Ab0HZGpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 02:45:04 -0400
In-Reply-To: <201008260557.o7Q5v8AU028127@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Wed, 25 Aug 2010 22:57:08 -0700

> From: Rasesh Mody <rmody@brocade.com>
> 
> This is the patch to fix the build break caused by multiple
> definitions of symbols between Brocade's FC/FCOE driver(BFA)
> and 10G Networking Driver(BNA).
> 
> Changes are:
> 
> 1. locally used functions are made static 
> 
> 2. unused functions are removed
> 
> 3. using unique namespaces for the function names that must be
> globally visible
> 
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Applied, thanks.
