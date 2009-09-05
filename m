From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: silence compiler warning
Date: Fri, 04 Sep 2009 20:33:18 -0700 (PDT)
Message-ID: <20090904.203318.112406812.davem@davemloft.net>
References: <4AA1B712.6060900@hp.com>
	<1252112881.27694.3.camel@violet>
	<4AA1C086.5000607@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44382
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934569AbZIEDdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 23:33:02 -0400
In-Reply-To: <4AA1C086.5000607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 04 Sep 2009 21:36:06 -0400

> Hi Marcel,
> 
> Marcel Holtmann wrote:
>> can we please add the err = -E... where it actually is needed and not
>> stupidly go ahead and silence compiler warnings with err = 0. This has
>> been posted before.
> 
> Sorry, I don't remember it being posted before.  If you look at the code
> though, err is correctly initialized, gcc just can't figure it out.  The
> choices I see are either what I originally posted, using uninitialized_var(err),
> or the patch below.  It doesn't matter to me.

uninitialized_var() would be absolutely wrong here, as then we'd
return garbage if such a path were actually possible.

Your original patch was fine and I'm going to apply it, thanks.
