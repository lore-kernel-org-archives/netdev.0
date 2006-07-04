From: Greg KH <greg@kroah.com>
Subject: Re: [RFC] change netdevice to use struct device instead of struct class_device
Date: Tue, 4 Jul 2006 15:31:01 -0700
Message-ID: <20060704223101.GA25275@kroah.com>
References: <20060703224719.GA14176@kroah.com> <44A9A345.8040706@garzik.org> <20060703231610.GA18352@kroah.com> <20060703.185747.74753207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:38331 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932303AbWGDWen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 18:34:43 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060703.185747.74753207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 03, 2006 at 06:57:47PM -0700, David Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Mon, 3 Jul 2006 16:16:10 -0700
> 
> > No, not really.  According to Documentation/ABI/testing/sysfs-class all
> > code that uses /sys/class/foo/ needs to be able to handle the fact that
> > those entries might be symlinks and not just directories.  Everything
> > that I know of already works properly because the input layer has had
> > symlinks in /sys/class/input for quite some time now.
> > 
> > Do you know of any tools that use /sys/class/net/ that can not handle
> > symlinks there?  I've been running this on my boxes for about a week now
> > with no noticeable issues.  Renaming interfaces works just fine too.
> 
> I do not think this change will cause any problems.

Great, thanks for looking.

Do you mind if I keep this in my tree, due to the dependancies on the
other driver core changes?

thanks,

greg k-h
