From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 3c52x: remove IRQF_SAMPLE_RANDOM from legacy
 MCA drivers.
Date: Tue, 19 Oct 2010 02:32:27 -0700 (PDT)
Message-ID: <20101019.023227.189701743.davem@davemloft.net>
References: <1287102111-5482-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50645
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752030Ab0JSJcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 05:32:05 -0400
In-Reply-To: <1287102111-5482-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 14 Oct 2010 20:21:51 -0400

> If you are genuinely using one of these legacy MCA drivers
> then you are tragically on hardware where you really don't
> have the extra CPU cycles to be wasting on this.
> 
> In addition, it makes two less cases for people to inadvertently
> blindly copy flags from without explicitly thinking whether it
> makes sense -- see the addition to feature-removal.txt as per
> commit 9d9b8fb0e5ebf4b0398e579f6061d4451fea3242.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thank you.
