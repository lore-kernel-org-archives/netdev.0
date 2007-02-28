From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH 2.6.20] kobject net ifindex + rename
Date: Wed, 28 Feb 2007 10:51:17 -0800
Message-ID: <20070228185117.GE6134@bougret.hpl.hp.com>
References: <20070228012741.GA3988@bougret.hpl.hp.com> <1172654165.3681.31.camel@johannes.berg>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux kernel mailing list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:63705 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932290AbXB1Swt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 13:52:49 -0500
Content-Disposition: inline
In-Reply-To: <1172654165.3681.31.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 28, 2007 at 10:16:05AM +0100, Johannes Berg wrote:
> Hi,
> 
> > 	Patch for 2.6.20 is attached.
> 
> ... and in the meantime netdevices aren't class_device any more :) IOW,
> your patch isn't going to work any more.

	That's why I always specify the kernel version. I'll look into
that, I'm sure it's not the end of the world ;-)

> Also, I think wireless could benefit from this as well.

	In which sense ? Wireless interface are regular netdevices.

> >         The kobject framework is well designed, so adding these
> > features is trivial change and won't run the risk of breaking anything
> > (famous last words). Obviously, hotplug apps are free to ignore those
> > additional features.
> 
> Why not just add this to base kobject_rename instead? That way,
> userspace is notified for all renames in sysfs.
> The patch then collapses down to the change in net's sysfs code to add
> the ifindex to the environment, and another change in kobject to invoke
> a new event when a name changes and show the old name.

	I'm just trying to follow the established pattern. Both
class_device_add() and class_device_del() are generating the
event. Also, I'm not sure if other subsystem would benefit from it, I
don't want to generate too many useless events.

> johannes

	Thanks !

	Jean

