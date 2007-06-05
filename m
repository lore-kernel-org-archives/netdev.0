From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2/5 revised][BNX2]: Add missing wait in bnx2_init_5709_context().
Date: Mon, 4 Jun 2007 21:23:51 -0400
Message-ID: <20070605012351.GE31462@havoc.gtf.org>
References: <1181001635.5275.13.camel@dell> <20070604233940.GB31462@havoc.gtf.org> <1181005129.7230.2.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andy@greyhouse.net,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39045 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbXFEBX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 21:23:56 -0400
Content-Disposition: inline
In-Reply-To: <1181005129.7230.2.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 04, 2007 at 05:58:49PM -0700, Michael Chan wrote:
> [BNX2]: Add missing wait in bnx2_init_5709_context().
> 
> For correctness, we need to wait for the MEM_INIT bit to be cleared
> in the BNX2_CTX_COMMAND register before proceeding.
> 
> [Added return -EBUSY when the MEM_INIT bit doesn't clear, suggested
> by Jeff Garzik.]
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

ACK


