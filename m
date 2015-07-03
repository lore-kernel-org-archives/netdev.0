From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: Make MLD packets to only be processed locally
Date: Fri, 03 Jul 2015 09:53:27 -0700 (PDT)
Message-ID: <20150703.095327.1203676778842027066.davem@davemloft.net>
References: <1435891252-3938-1-git-send-email-hermin.anggawijaya@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hermin.anggawijaya@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754196AbbGCQx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 12:53:28 -0400
In-Reply-To: <1435891252-3938-1-git-send-email-hermin.anggawijaya@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>
Date: Fri,  3 Jul 2015 14:40:52 +1200

> Before commit daad151263cf ("ipv6: Make ipv6_is_mld() inline and use it
> from ip6_mc_input().") MLD packets were only processed locally. After the
> change, a copy of MLD packet goes through ip6_mr_input, causing
> MRT6MSG_NOCACHE message to be generated to user space.
> 
> Make MLD packet only processed locally.
> 
> Fixes: daad151263cf ("ipv6: Make ipv6_is_mld() inline and use it from ip6_mc_input().")
> Signed-off-by: Hermin Anggawijaya <hermin.anggawijaya@alliedtelesis.co.nz>

Applied and queued up for -stable, thanks.
