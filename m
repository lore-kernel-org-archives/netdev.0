From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH v4 1/1 net-next] net: fec: add napi support to improve proformance
Date: Mon, 4 Feb 2013 19:33:04 +0000 (UTC)
Message-ID: <loom.20130204T203257-683@post.gmane.org>
References: <1359433903-15605-1-git-send-email-Frank.Li@freescale.com> <20130129.141800.2181207237672109119.davem@davemloft.net> <CAHrpEqQXH+n7K4L1m5yRiamp3CG9MPWhX+tNBD+brzArJy5WoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:54366 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753653Ab3BDTdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 14:33:21 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1U2RnN-0001fh-TB
	for netdev@vger.kernel.org; Mon, 04 Feb 2013 20:33:37 +0100
Received: from jimbax.plus.com ([81.174.248.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 20:33:37 +0100
Received: from jim_baxter by jimbax.plus.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 20:33:37 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Li <lznuaa <at> gmail.com> writes:

> 
> 2013/1/30 David Miller <davem <at> davemloft.net>:
> > it is recommended to also to TX reclaim processing
> > in the NAPI handler as well, in fact it's best to make the hardware
> > interrupt handler do nothing other than trigger NAPI and then
> > move everything that was in your hardware interrupt handler into
> > NAPI poll instead.
> 
> Okay, I will work on this soon.
> 


This might be related but I have found on the Sabre AI Revision TO1.1 that the 
NAPI patch causes a 10% reduction in speed, is this expected?
