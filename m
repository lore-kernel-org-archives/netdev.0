From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 20:06:43 -0600
Message-ID: <m1y7l53pl8.fsf@ebiederm.dsl.xmission.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
	<4616B9A5.7090800@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:53179 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965042AbXDGCI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 22:08:29 -0400
In-Reply-To: <4616B9A5.7090800@candelatech.com> (Ben Greear's message of "Fri,
	06 Apr 2007 14:20:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear <greearb@candelatech.com> writes:

> Is there any way to tell for certain if an interface is a etun or not?  Maybe
> a file could be found (or not) in sysfs somewhere?

Link for any decent network driver ethtool -i <interface>

> Also, how do you find the peer device from user-space?  This would be very
> useful
> for anyone trying to manage these devices with a user-space program.

Currently "ethtool -S <interface>"
And read the partner_ifindex.

Further whoever generates the pair specifies the initial set of names.

> When you are creating new devices, I think you should check to make
> sure there isn't already a device with that name.

alloc_netdev doesn't let you register two devices with the same name,
and I check the return status of alloc_netdev. 

> In general though, I look forward to this being in the kernel so I can drop
> my redirect device code from my out-of-tree patch.

Thanks.

Eric
