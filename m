From: Greg KH <greg@kroah.com>
Subject: Re: netvsc NAPI patch process
Date: Fri, 27 Jan 2017 08:54:06 +0100
Message-ID: <20170127075406.GC31443@kroah.com>
References: <20170126100405.0eac2dea@xeon-e3>
 <20170126.130646.2180422281199593870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, kys@microsoft.com,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:35012 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754291AbdA0HyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 02:54:20 -0500
Content-Disposition: inline
In-Reply-To: <20170126.130646.2180422281199593870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2017 at 01:06:46PM -0500, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 26 Jan 2017 10:04:05 -0800
> 
> > I have a working set of patches to enable NAPI in the netvsc driver.
> > The problem is that it requires a set of patches to vmbus layer as well.
> > Since vmbus patches have been going through char-misc-next tree rather
> > than net-next, it is difficult to stage these.
> > 
> > How about if I send the vmbus patches through normal driver-devel upstream
> > and during the 4.10 merge window send the last 3 patches for NAPI for linux-net
> > tree to get into 4.10?
> 
> Another option is that the char-misc-next folks create a branch with just
> the commits you need for NAPI, I pull that into net-next, and then you
> can submit the NAPI changes to me.

I can easily do that, or I have no problem with the vmbus changes going
through the net-next tree, if they are sane (i.e. let me review them
please...)  Which ever is easier for the networking developers, their
tree is much crazier than the tiny char-misc tree is :)

thanks,

greg k-h
