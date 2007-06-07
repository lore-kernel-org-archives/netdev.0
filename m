From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 07 Jun 2007 08:22:42 -0400
Message-ID: <1181218962.4064.48.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>
	 <20070606.165356.102125635.davem@davemloft.net>
	 <1181178481.4064.121.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:15904 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbXFGMWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 08:22:45 -0400
Received: by py-out-1112.google.com with SMTP id a29so807463pyi
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 05:22:45 -0700 (PDT)
In-Reply-To: <1181178481.4064.121.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 21:08 -0400, jamal wrote:

> It's too depressing - so i came back here for a break ;->

I am sure you would agree it was too depressing ;->

> As a side note: You will have to do a lot of surgery to the current code
> to make tx run on multi CPUs. It needs some experimenting to get right.
> And i am begining to like Herberts changes ;->

On clear morning thinking:
There is a scenario where multi CPUs will benefit and that is if a
single CPU cant pump fast enough to fill the wire. I think this may have
been your initial comment but we digressed into the locks. I still think
the bottleneck on the tx that needs to improve is IO (DMA, PCI/X/E etc).

And as you know though that requires some major surgery (given the
multiple producer single consumer approach we have today) and certainly
Peters patches dont add value in that direction.

cheers,
jamal

