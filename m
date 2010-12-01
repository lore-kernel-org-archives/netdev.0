From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: check for assigned mac before adopting the
 slaves mac address
Date: Wed, 01 Dec 2010 11:43:16 -0800 (PST)
Message-ID: <20101201.114316.70199490.davem@davemloft.net>
References: <AANLkTinXD6p25BoN0+JuvFM9v6K-oibOAFJebP08F29N@mail.gmail.com>
	<27001.1291231268@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dpstrand@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40971
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756576Ab0LATmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 14:42:50 -0500
In-Reply-To: <27001.1291231268@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Wed, 01 Dec 2010 11:21:08 -0800

> 
> From: David Strand <dpstrand@gmail.com>
> 
> Restore the check for an unassigned mac address before adopting the
> first slaves as it's own. The change in behavior was introduced by:
> 
> commit c20811a79e671a6a1fe86a8c1afe04aca8a7f085
> Author: Jiri Pirko <jpirko@redhat.com>
> 
>     bonding: move dev_addr cpy to bond_enslave
> 
> 
> Signed-off-by: David Strand <dpstrand@gmail.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks.
