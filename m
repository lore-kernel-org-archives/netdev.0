From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] af-packet: Add flag to distinguish VID 0 from
 no-vlan.
Date: Wed, 01 Jun 2011 21:18:39 -0700 (PDT)
Message-ID: <20110601.211839.1746668346631660694.davem@davemloft.net>
References: <1306946950-29360-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab1FBESl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:18:41 -0400
In-Reply-To: <1306946950-29360-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Wed,  1 Jun 2011 09:49:10 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> Currently, user-space cannot determine if a 0 tcp_vlan_tci
> means there is no VLAN tag or the VLAN ID was zero.
> 
> Add flag to make this explicit.  User-space can check for
> TP_STATUS_VLAN_VALID || tp_vlan_tci > 0, which will be backwards
> compatible. Older could would have just checked for tp_vlan_tci,
> so it will work no worse than before.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied.
