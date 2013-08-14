From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/3] net/usb/r8152: support aggregation
Date: Wed, 14 Aug 2013 11:02:56 +0800
Message-ID: <20698A1C08B24B92B3CD1D84AC85A175@realtek.com.tw>
References: <1376383742.1681.1.camel@linux-fkkt.site><9E410853D1BD483E9479C175D5E72EB6@realtek.com.tw><1376407030.3033.13.camel@linux-fkkt.site> <20130813.164118.1992860501009385037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>, <oneukum@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130813.164118.1992860501009385037.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, August 14, 2013 7:41 AM
> To: oneukum@suse.de
> Cc: Hayeswang; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: Re: [PATCH net-next 1/3] net/usb/r8152: support aggregation
> 
[...]
> > I don't understand what problem the function is supposed to 
> fix. As long
> > as I don't understand it I cannot say for sure whether it 
> is correct.
> > There seems no obvious reason for a memory barrier, but 
> there may be a
> > hidden reason I don't see.
> 
> Hayes, when Oliver asks you "Against what is the memory 
> barrier?" he is asking
> you which memory operations you are trying to order.
> 
> You do not explain this in your commit message, nor do you 
> explain it with a
> suitable comment.  This is not acceptable.
> 
> It is absolutely critical, that any time you add a memory 
> barrier, you add a
> comment above the new memory barrier explaining exactly what 
> the barrier is
> trying to achieve.
> 
> In fact, this is required by our coding standards.

I just want to make sure the rx_desc and rx_data are set correctly before
they are used. However, I study some examples and information from internet,
and I think that the memory barries is not necessary here. Therefore, I would
remove them later.
 
Best Regards,
Hayes
