From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH next] staging-p80211: Kill directly reference of c
Date: Fri, 5 Dec 2008 18:41:23 -0800
Message-ID: <20081206024123.GB31523@suse.de>
References: <4939456D.8010003@cn.fujitsu.com> <20081205154446.GB28030@suse.de> <4939E35D.4010102@cn.fujitsu.com> <20081205.183015.127189402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wangchen@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45042 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641AbYLFCw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 21:52:59 -0500
Content-Disposition: inline
In-Reply-To: <20081205.183015.127189402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 05, 2008 at 06:30:15PM -0800, David Miller wrote:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Sat, 06 Dec 2008 10:28:45 +0800
> 
> > Greg KH said the following on 2008-12-5 23:44:
> > > thanks for the patch, I'll queue it up,
> > 
> > I'm doing this "kill netdev->priv" work on Dave's net-next tree now.
> > So, will it be better to let Dave apply this to his net-next instead
> > you apply it?
> > Just suggestion :)
> 
> Yes, I would prefer it be done this way so I can do the final
> kill of the netdev->priv member without having to wait for
> a dependency on the staging tree :)

Feel free to take it yourself, I have no objection to anyone else
taking drivers/staging/ patches if they want to.  You're the first one
to be so brave :)

You can add a:
	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
to the patch.

thanks,

greg k-h
