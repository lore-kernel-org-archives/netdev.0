From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: properly initialize L5 features
Date: Thu, 08 Dec 2011 19:56:12 -0500 (EST)
Message-ID: <20111208.195612.1797303038274788707.davem@davemloft.net>
References: <1323367447-28074-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, barak@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab1LIA4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2011 19:56:15 -0500
In-Reply-To: <1323367447-28074-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 8 Dec 2011 20:04:07 +0200

> The code is missing initialization of NO_FCOE_FLAG and NO_ISCSI*FLAGS
> when CONFIG_CNIC is not selected.
> This causes panic during driver load since commit
> 1d187b34daaecbb87aa523ba46b92930a388cb21 where NO_FCOE tested 
> unconditionally (outside #ifdef BCM_CNIC  structure) and
> accessed fp[FCOE_IDX] which is not allocated.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 

Applied.
