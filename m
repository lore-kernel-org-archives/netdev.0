From: David Miller <davem@davemloft.net>
Subject: Re: [2/5 revised][BNX2]: Add missing wait in
 bnx2_init_5709_context().
Date: Mon, 04 Jun 2007 21:22:33 -0700 (PDT)
Message-ID: <20070604.212233.52182487.davem@davemloft.net>
References: <20070604233940.GB31462@havoc.gtf.org>
	<1181005129.7230.2.camel@dell>
	<20070605012351.GE31462@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, andy@greyhouse.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37148
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754296AbXFEEWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 00:22:19 -0400
In-Reply-To: <20070605012351.GE31462@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Mon, 4 Jun 2007 21:23:51 -0400

> On Mon, Jun 04, 2007 at 05:58:49PM -0700, Michael Chan wrote:
> > [BNX2]: Add missing wait in bnx2_init_5709_context().
> > 
> > For correctness, we need to wait for the MEM_INIT bit to be cleared
> > in the BNX2_CTX_COMMAND register before proceeding.
> > 
> > [Added return -EBUSY when the MEM_INIT bit doesn't clear, suggested
> > by Jeff Garzik.]
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> ACK

Applied, thanks.
