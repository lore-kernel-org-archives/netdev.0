From: "Dhananjay Phadke" <dhananjay@netxen.com>
Subject: Re: [PATCH 1/1] netxen: Load firmware during probe, dma watchdog fix.
Date: Wed, 25 Jul 2007 09:48:56 +0530
Message-ID: <ab901500707242118q27cb9eddqe69f01275b809b3@mail.gmail.com>
References: <20070719091108.839200259@netxen.com>
	 <20070719091131.467737478@netxen.com> <46A662D5.3020201@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com,
	"Wen Xiong" <wenxiong@us.ibm.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:49960 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbXGYES5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2007 00:18:57 -0400
Received: by an-out-0708.google.com with SMTP id d31so11848and
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 21:18:56 -0700 (PDT)
In-Reply-To: <46A662D5.3020201@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

You committed old patch, which I had asked to ignore for two newer patches.

[PATCH 1/1] netxen: Load firmware during probe, dma watchdog fix.

is wrong patch that went in, instead please commit:

[PATCH 1/2] netxen: IMEZ multiport card 2nd port issue, dma watchdog fix
[PATCH 2/2] netxen: Fix interrupt handling for multiport adapters

Thanks,
Dhananjay

On 7/25/07, Jeff Garzik <jeff@garzik.org> wrote:
> dhananjay@netxen.com wrote:
> > The firmware should be loaded after resetting hardware during PCI probe,
> > besides module unload. This fixes issue with 2nd port of multiport adapter
> > on powerpc blades. This patch also fixes a bug that PCI resources are not
> > freed if dma watchdog shutdown failed. The dma watchdog poll messages
> > during module unload are also suppressed.
> >
> > Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> > Signed-off-by: Milan Bag <mbag@netxen.com>
> > Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
>
> applied
>
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
