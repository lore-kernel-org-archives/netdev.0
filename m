From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: Fix up type mismatch in smc_drv_resume().
Date: Fri, 11 Dec 2009 15:17:22 -0800 (PST)
Message-ID: <20091211.151722.243020071.davem@davemloft.net>
References: <20091211064226.GA7625@linux-sh.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lethal@linux-sh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40638
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758471AbZLKXRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 18:17:16 -0500
In-Reply-To: <20091211064226.GA7625@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mundt <lethal@linux-sh.org>
Date: Fri, 11 Dec 2009 15:42:27 +0900

> smc_drv_resume() takes a struct device, while smc_enable_device() takes a
> platform device. This fixes up the smc_enable_device() callsite with the
> proper pointer.
> 
> It's not obvious when this change was introduced, as git history doesn't
> go back that far. Presumably the resume code has always been broken in
> this fashion.
> 
> Signed-off-by: Paul Mundt <lethal@linux-sh.org>

Applied.
