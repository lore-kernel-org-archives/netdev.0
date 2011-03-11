From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 3/8] macb: convert printk to pr_ and friends
Date: Fri, 11 Mar 2011 00:09:28 +0000
Message-ID: <20110311000928.GI6198@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-4-git-send-email-jamie@jamieiles.com>
 <1299797284.20104.162.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50773 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab1CKAJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 19:09:37 -0500
Received: by wwa36 with SMTP id 36so2600812wwa.1
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 16:09:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1299797284.20104.162.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 02:48:04PM -0800, Joe Perches wrote:
> On Thu, 2011-03-10 at 10:10 +0000, Jamie Iles wrote:
> > macb is already using the dev_dbg() and friends helpers so use pr_foo()
> > along with a pr_fmt() definition to make the printing a little cleaner.
> > Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> 
> Hi Jamie.
> 
> Because these conversions use a struct net_device,
> they would be better as:
> 
> 	netdev_<foo>(struct net_device *dev, const char *fmt, ...)

Ahh nice, I hadn't come across those before.  I'll update all of the 
pr_* and dev_* statements to use the netdev variants.

Thanks for that!

Jamie
