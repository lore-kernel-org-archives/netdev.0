From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar: ensure ECNTRL[R100] is cleared on link state
 change
Date: Tue, 06 Jan 2009 14:08:17 -0800 (PST)
Message-ID: <20090106.140817.59130790.davem@davemloft.net>
References: <1231275171-21388-1-git-send-email-galak@kernel.crashing.org>
	<8E33B4C2-F1E3-4C64-86E4-6EAA4C7151C5@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, leo@rock.ap.freescale.net
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39742
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752210AbZAFWIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 17:08:16 -0500
In-Reply-To: <8E33B4C2-F1E3-4C64-86E4-6EAA4C7151C5@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Fleming <afleming@freescale.com>
Date: Tue, 6 Jan 2009 14:56:25 -0600

> 
> On Jan 6, 2009, at 2:52 PM, Kumar Gala wrote:
> 
> > From: Leo Li <leo@rock.ap.freescale.net>
> >
> > When changing the link between 100Mbps and 1Gbps in SGMII mode it was
> > found out that the link would stop working.  The issue is that ECNTRL[R100]
> > needs to be cleared when in 1Gbps mode.  Older reference manuals didn't
> > require the explicitly clearing but has since been found it that it is
> > needed.
> >
> > Signed-off-by: Li Yang <leoli@freescale.com>
> > Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> 
> Acked-by: Andy Fleming <afleming@freescale.com>

Applied, thanks everyone.
