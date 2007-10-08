From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24] tg3: fix ethtool autonegotiate flags
Date: Mon, 08 Oct 2007 01:09:02 -0700 (PDT)
Message-ID: <20071008.010902.32370566.davem@davemloft.net>
References: <20071002201634.GE9140@gospo.rdu.redhat.com>
	<1191362576.5961.15.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, jeff@garzik.org, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752458AbXJHIJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 04:09:04 -0400
In-Reply-To: <1191362576.5961.15.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 02 Oct 2007 15:02:56 -0700

> On Tue, 2007-10-02 at 16:16 -0400, Andy Gospodarek wrote:
> > Adding that flag in tg3_set_settings seemed like the most logical
> > place
> > since the driver works fine on boot.  This is just an issue when
> > re-enabling autonegotiation, so we should probably nip it there.
> > 
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> We also noticed this issue recently, but didn't pay too much attention
> to it since it was more of a "cosmetic" issue.  The driver behaves the
> same since we rely on cmd->autoneg to decide whether to enable autoneg
> or not.  Your fix seems reasonable to me.  Thanks.
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone!
