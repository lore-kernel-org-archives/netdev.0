From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fix section mismatch in fec.c
Date: Tue, 20 Oct 2009 18:51:48 -0700 (PDT)
Message-ID: <20091020.185148.193710136.davem@davemloft.net>
References: <200910201600.10545.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sfking@fdwdc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32911
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751247AbZJUBvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 21:51:25 -0400
In-Reply-To: <200910201600.10545.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven King <sfking@fdwdc.com>
Date: Tue, 20 Oct 2009 16:00:10 -0700

> fec_enet_init is called by both fec_probe and fec_resume, so it shouldn't 
> be marked as __init.
> 
> Signed-off-by: Steven King <sfking@fdwdc.com>

Applied, thanks.
