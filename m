From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 2.6.24] tg3: fix ethtool autonegotiate flags
Date: Tue, 2 Oct 2007 17:16:59 -0400
Message-ID: <20071002211658.GF9140@gospo.rdu.redhat.com>
References: <20071002201634.GE9140@gospo.rdu.redhat.com> <1191362576.5961.15.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50803 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbXJBVRF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:17:05 -0400
Content-Disposition: inline
In-Reply-To: <1191362576.5961.15.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 02, 2007 at 03:02:56PM -0700, Michael Chan wrote:
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
> 

I completely agree that it's cosmetic, it just seems like something
decent to toss in there since it's the kind of thing others will start
complaining about. 


