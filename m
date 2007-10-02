From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.24] tg3: fix ethtool autonegotiate flags
Date: Tue, 02 Oct 2007 15:02:56 -0700
Message-ID: <1191362576.5961.15.camel@dell>
References: <20071002201634.GE9140@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, jeff@garzik.org,
	"netdev" <netdev@vger.kernel.org>
To: "Andy Gospodarek" <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1715 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbXJBVEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:04:04 -0400
In-Reply-To: <20071002201634.GE9140@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-02 at 16:16 -0400, Andy Gospodarek wrote:
> Adding that flag in tg3_set_settings seemed like the most logical
> place
> since the driver works fine on boot.  This is just an issue when
> re-enabling autonegotiation, so we should probably nip it there.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

We also noticed this issue recently, but didn't pay too much attention
to it since it was more of a "cosmetic" issue.  The driver behaves the
same since we rely on cmd->autoneg to decide whether to enable autoneg
or not.  Your fix seems reasonable to me.  Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>

