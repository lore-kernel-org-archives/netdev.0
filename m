From: David Miller <davem@davemloft.net>
Subject: Re: atm: panic when loading clip 2nd time
Date: Sun, 21 Oct 2007 16:24:54 -0700 (PDT)
Message-ID: <20071021.162454.71185083.davem@davemloft.net>
References: <47152758.5000900@oracle.com>
	<29495f1d0710161433h6e4e90a6r32c89c2a89af2f90@mail.gmail.com>
	<20071019180236.cbc000a2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nish.aravamudan@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, chas@cmf.nrl.navy.mil
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39687
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbXJUXYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 19:24:40 -0400
In-Reply-To: <20071019180236.cbc000a2.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 19 Oct 2007 18:02:36 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> net/atm/clip.c crashes the kernel if it (module) is loaded, removed,
> and then loaded again.  Its exit call to neigh_table_clear()
> should destroy the cache after freeing it.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Looks good to me, applied, thanks!
