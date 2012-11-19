From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 200/493] irda: remove use of __devinit
Date: Mon, 19 Nov 2012 12:25:32 -0800
Message-ID: <20121119122532.4903bea3@nehalam.linuxnetplumber.net>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
	<1353349642-3677-200-git-send-email-wfp5p@virginia.edu>
	<20121119.140654.780679585475336928.davem@davemloft.net>
	<20121119192121.GA16694@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, wfp5p@virginia.edu,
	samuel@sortiz.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52041 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754778Ab2KSU0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2012 15:26:40 -0500
In-Reply-To: <20121119192121.GA16694@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Nov 2012 11:21:21 -0800
Greg KH <gregkh@linuxfoundation.org> wrote:

> On Mon, Nov 19, 2012 at 02:06:54PM -0500, David Miller wrote:
> > 
> > It is absolutely not reasonable to post nearly 500 patches all
> > at the same time.
> > 
> > Do not do this ever again.
> 
> Bill did this with the assumption that I would take them through my
> driver-core tree, as I asked that he do this work.  The 000 message said
> that, but that wasn't sent out to all of the recipients, so I can
> understand how you didn't see this.
> 
> Also, I was the only one that got all 500 emails, everyone else should
> have only seen a small quantity.
> 
> As you object to these, that's fine, I'll not apply anything to my
> treethat touches the drivers/net/ or net/ tree at this point in time, is
> that ok?
> 
> But the end goal is to drop CONFIG_HOTPLUG entirely, and these __dev*
> markings, as they don't do anything anymore.
> 
> thanks,
> 
> greg k-h
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This seems like a case where a pull-request should have been used,
rather spamming everyone and every mailing list.
