From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: use msecs_to_jiffies for conversions
Date: Mon, 08 Jun 2015 15:54:25 -0700 (PDT)
Message-ID: <20150608.155425.1095846044935528227.davem@davemloft.net>
References: <1433790988-14635-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32902 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932201AbbFHWy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 18:54:26 -0400
In-Reply-To: <1433790988-14635-1-git-send-email-hofrat@osadl.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Mon,  8 Jun 2015 21:16:28 +0200

> API compliance scanning with coccinelle flagged:
> ./drivers/atm/iphase.c:2621:4-20:
>         WARNING: timeout (50) seems HZ dependent
> 
> Numeric constants passed to schedule_timeout() make the effective
> timeout HZ dependent which does not seem intended.
> Fixed up by converting the constant to jiffies with msecs_to_jiffies()
> As this driver was introduced in the early 2.3 series it is most 
> likely assuming HZ=100 so the constant 50 is converted to 500ms.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied, thanks.
