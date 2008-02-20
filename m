From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NETLABEL] Minor cleanup: remove unused method
 definition
Date: Wed, 20 Feb 2008 00:27:11 -0800 (PST)
Message-ID: <20080220.002711.181069536.davem@davemloft.net>
References: <eb3ff54b0802190625v5315aac9m7ffd580b30bce8cd@mail.gmail.com>
	<200802191108.27168.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramirose@gmail.com, netdev@vger.kernel.org, casey@schaufler-ca.com
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753655AbYBTI0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 03:26:34 -0500
In-Reply-To: <200802191108.27168.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 19 Feb 2008 11:08:27 -0500

> On Tuesday 19 February 2008 9:25:31 am Rami Rosen wrote:
> > Hi,
> >
> > This patch removes definition of netlbl_cfg_cipsov4_del() method in
> > netlabel/netlabel_kapi.c and in include/net/netlabel.h as it is not
> > used.
> >
> >
> > Regards,
> > Rami Rosen
> >
> >
> > Signed-off-by: Rami Rosen <ramirose@gmail.com>
> 
> This was added for use by Smack (and any other LSMs which want to 
> configure NetLabel directly) and since this is an area that is 
> undergoing a lot of churn at this point I'd prefer if this function was 
> left in place for the time being.
> 
> At a later date if this function is still unused, I'll gladly ack it's 
> removal or do so myself.

Ok, let's leave it in for now.
