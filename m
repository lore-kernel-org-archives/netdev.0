From: David Miller <davem@davemloft.net>
Subject: Re: [0/6] vxge: a few bug fixes and performance tweaks for vxge
Date: Wed, 05 Aug 2009 13:11:20 -0700 (PDT)
Message-ID: <20090805.131120.134126260.davem@davemloft.net>
References: <20090804202013.GA9924@neterion.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben.lahaise@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33140
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752265AbZHEULM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 16:11:12 -0400
In-Reply-To: <20090804202013.GA9924@neterion.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <ben.lahaise@neterion.com>
Date: Tue, 4 Aug 2009 16:20:13 -0400

> This patch series consists of several bug fixes and performance enhancements 
> for the vxge driver.  They have passed internal QA.  Please apply.
> 
> 	[1/6] vxge: don't drop frame on tx queue full
> 	[2/6] vxge: fix pktgen hangs (don't abuse skb->cb[])
> 	[3/6] vxge: improve tx performance by using mmiowb() instead of wmb()
> 	[4/6] vxge: prefetch RxD descriptors
> 	[5/6] vxge: prefetch skb->data
> 	[6/6] vxge: Version update
> 
> Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>

All applied to net-next-2.6, thanks.
