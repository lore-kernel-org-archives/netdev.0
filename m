From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] staging-p80211: Kill directly reference of c
Date: Fri, 05 Dec 2008 19:06:03 -0800 (PST)
Message-ID: <20081205.190603.130855663.davem@davemloft.net>
References: <4939E35D.4010102@cn.fujitsu.com>
	<20081205.183015.127189402.davem@davemloft.net>
	<20081206024123.GB31523@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34241
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751907AbYLFDGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 22:06:02 -0500
In-Reply-To: <20081206024123.GB31523@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <gregkh@suse.de>
Date: Fri, 5 Dec 2008 18:41:23 -0800

> On Fri, Dec 05, 2008 at 06:30:15PM -0800, David Miller wrote:
> > From: Wang Chen <wangchen@cn.fujitsu.com>
> > Date: Sat, 06 Dec 2008 10:28:45 +0800
> > 
> > > Greg KH said the following on 2008-12-5 23:44:
> > > > thanks for the patch, I'll queue it up,
> > > 
> > > I'm doing this "kill netdev->priv" work on Dave's net-next tree now.
> > > So, will it be better to let Dave apply this to his net-next instead
> > > you apply it?
> > > Just suggestion :)
> > 
> > Yes, I would prefer it be done this way so I can do the final
> > kill of the netdev->priv member without having to wait for
> > a dependency on the staging tree :)
> 
> Feel free to take it yourself, I have no objection to anyone else
> taking drivers/staging/ patches if they want to.  You're the first one
> to be so brave :)
> 
> You can add a:
> 	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
> to the patch.

Great, I'll do that, thanks Greg!
