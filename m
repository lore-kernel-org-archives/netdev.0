From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 v2] netdev: bfin_mac: drop useless IRQF_SHARED from
 Blackfin EMAC interrupt
Date: Fri, 29 May 2009 15:49:38 -0700 (PDT)
Message-ID: <20090529.154938.254028525.davem@davemloft.net>
References: <1243404615-25879-2-git-send-email-vapier@gentoo.org>
	<1243604385-27159-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	michael.hennerich@analog.com, cooloney@kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33947
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751254AbZE2Wti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:49:38 -0400
In-Reply-To: <1243604385-27159-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri, 29 May 2009 09:39:45 -0400

> From: Michael Hennerich <michael.hennerich@analog.com>
> 
> The IRQ used by the Blackfin EMAC is internal to the peripheral and cannot
> be used to generate any other interrupt, so there is no point in marking it
> as IRQF_SHARED.
> 
> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>

Applied to net-next-2.6
