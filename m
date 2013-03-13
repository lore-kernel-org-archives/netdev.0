From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: 5715 does not link up when autoneg off
Date: Wed, 13 Mar 2013 10:00:11 -0400 (EDT)
Message-ID: <20130313.100011.730650469624132866.davem@davemloft.net>
References: <1363138368-10651-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcinmiotk81@gmail.com, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623Ab3CMOAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:00:02 -0400
In-Reply-To: <1363138368-10651-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Tue, 12 Mar 2013 18:32:48 -0700

> From: Nithin Sujir <nsujir@broadcom.com>
> 
> Commit d13ba512cbba7de5d55d7a3b2aae7d83c8921457 cleaned up the autoneg
> advertisement by removing some dead code. One effect of this change was that
> the advertisement register would not be updated if autoneg is turned off.
> 
> This exposed a bug on the 5715 device w.r.t linking. The 5715 defaults
> to advertise only 10Mb Full duplex. But with autoneg disabled, it needs
> the configured speed enabled in the advertisement register to link up.
> 
> This patch adds the work around to advertise all speeds on the 5715 when
> autoneg is disabled.
> 
> Reported-by: Marcin Miotk <marcinmiotk81@gmail.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
