From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Bonding simplifications and netns support
Date: Thu, 29 Oct 2009 23:25:23 -0700 (PDT)
Message-ID: <20091029.232523.66969302.davem@davemloft.net>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42108
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755836AbZJ3GY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 02:24:59 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 29 Oct 2009 17:16:54 -0700

> I recently had it pointed out to me that the bonding driver does not
> work in a network namespace.  So I have simplified the bonding driver
> a bit, added support for ip link add and ip link del, and finally made
> the bonding driver work in multiple network namespaces.
> 
> The most note worthy change in the patchset is the addition of support
> in the networking core for registering a sysfs group for a device.
> 
> Using this in the bonding driver simplifies the code and removes a
> userspace race between actions triggered by the netlink event and the
> bonding sysfs attributes appearing.

I have no objections to these patches, but I'd like the bonding
folks to have a chance to look at it before I apply to net-next-2.6

One question though, are you sure this clever extra slot scheme
in patch #1 works for, f.e., a bond of wireless devices?  It seems
like it would work out, but I wanted to ask to make sure you
considered that case.

Thanks.
