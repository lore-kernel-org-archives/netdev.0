From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 200/493] irda: remove use of __devinit
Date: Mon, 19 Nov 2012 11:21:21 -0800
Message-ID: <20121119192121.GA16694@kroah.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
 <1353349642-3677-200-git-send-email-wfp5p@virginia.edu>
 <20121119.140654.780679585475336928.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wfp5p@virginia.edu, samuel@sortiz.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:40509 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab2KSTVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 14:21:25 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so3682321pbc.19
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2012 11:21:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121119.140654.780679585475336928.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 19, 2012 at 02:06:54PM -0500, David Miller wrote:
> 
> It is absolutely not reasonable to post nearly 500 patches all
> at the same time.
> 
> Do not do this ever again.

Bill did this with the assumption that I would take them through my
driver-core tree, as I asked that he do this work.  The 000 message said
that, but that wasn't sent out to all of the recipients, so I can
understand how you didn't see this.

Also, I was the only one that got all 500 emails, everyone else should
have only seen a small quantity.

As you object to these, that's fine, I'll not apply anything to my
treethat touches the drivers/net/ or net/ tree at this point in time, is
that ok?

But the end goal is to drop CONFIG_HOTPLUG entirely, and these __dev*
markings, as they don't do anything anymore.

thanks,

greg k-h
