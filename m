From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: Re: [RFC PATCH net-next] net: rename group sysfs entry to
 netdev_group
Date: Thu, 10 Feb 2011 11:11:35 +0200
Message-ID: <20110210091135.GA24889@cormyr>
References: <1297248769-28530-1-git-send-email-dfeng@redhat.com>
 <20110209.140323.39178091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dfeng@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	therbert@google.com, ebiederm@xmission.com, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:32885 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753306Ab1BJJME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 04:12:04 -0500
Content-Disposition: inline
In-Reply-To: <20110209.140323.39178091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 09, 2011 at 02:03:23PM -0800, David Miller wrote:
> From: Xiaotian feng <dfeng@redhat.com>
> Date: Wed,  9 Feb 2011 18:52:49 +0800
> 
> > From: Xiaotian Feng <dfeng@redhat.com>
> > 
> > commit a512b92 adds sysfs entry for net device group, but
> > before this commit, tun also uses group sysfs, so after this
> > commit checkin, kernel warns like this:
> >     sysfs: cannot create duplicate filename '/devices/virtual/net/vnet0/group'
> > 
> > Since tun has used this for years, rename sysfs under tun might
> > break existing userspace, so rename group sysfs entry for net device
> > group is a better choice.

I was not aware of that, sorry for breaking things :)
