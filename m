From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: bcmgenet: PHY initialization rework
Date: Mon, 20 Jul 2015 20:48:32 -0700 (PDT)
Message-ID: <20150720.204832.1520625602781168041.davem@davemloft.net>
References: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbbGUDsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:48:33 -0400
In-Reply-To: <1437087079-21678-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 16 Jul 2015 15:51:13 -0700

> This patch series reworks how we perform PHY initialization and resets in the
> GENET driver. Although this contains mostly fixes, some of the changes are a
> bit too intrusive to be backported to 'net' at the moment.
> 
> Some of the motivations behind these changes were to reduce the time spent in how
> performing MDIO transactions, since it is better to perform then when we have
> interrupts enabled. This reduces the bring-up time of GENET from ~600 msecs down
> to ~8 msecs, and about the same time for suspend/resume.
> 
> Since I do not currently have a system which is not DT-aware, can you (Petri,
> Jaedon) give this a try and confirm things keep working as expected?

Series applied, thanks Florian.
