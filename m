From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove write-only variable from pktgen_thread
Date: Thu, 30 Aug 2007 22:46:57 -0700 (PDT)
Message-ID: <20070830.224657.28395409.davem@davemloft.net>
References: <46D572FA.9090302@openvz.org>
	<20070829213356.GC18542@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, akpm@osdl.org, oleg@tv-sign.ru,
	containers@lists.osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: sukadev@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43964
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751052AbXHaFq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:46:58 -0400
In-Reply-To: <20070829213356.GC18542@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sukadev@us.ibm.com
Date: Wed, 29 Aug 2007 14:33:56 -0700

> Pavel Emelianov [xemul@openvz.org] wrote:
> | The pktgen_thread.pid is set to current->pid and is never used
> | after this. So remove this at all.
> | 
> | Found during isolating the explicit pid/tgid usage.
> | 
> | Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Good observation that its not being used :-)
> 
> Acked-by: Sukadev Bhattiprolu <sukadev@us.ibm.com>

Patch applied, thanks.
