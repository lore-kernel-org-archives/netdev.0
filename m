From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] net/core: Save the port number a netdevice uses
Date: Wed, 26 May 2010 12:08:52 +0300
Message-ID: <20100526090850.GB28748@mtldesk030.lab.mtl.com>
References: <20100526081702.GA17160@mtldesk030.lab.mtl.com>
	<20100526.013926.28807066.davem@davemloft.net>
	<20100526084523.GA28748@mtldesk030.lab.mtl.com>
	<20100526.015526.102555441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: eli@mellanox.co.il, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, rdreier@cisco.com,
	yevgenyp@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45858 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752422Ab0EZJIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 05:08:44 -0400
Content-Disposition: inline
In-Reply-To: <20100526.015526.102555441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 26, 2010 at 01:55:26AM -0700, David Miller wrote:
> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Wed, 26 May 2010 11:45:23 +0300
> 
> 
> What's wrong with using the existing dev_id sysfs file name and saying
> that it means the port number of the card?
> 
> Nobody, and I really mean nobody, uses this thing any more.
> 
> It used to be a way for devices like the qeth driver to get it's
> IPV6 EUI48 value set properly for local IPV6 addresses assigned
> to the device, but that got fixed in a different way.
> 
> So we can use this value however we wish now, and it defaults to zero
> for every single device now, and is propagated across VLAN devices,
> which is perfect.

OK. So if I understand you correctly, you think that I should not
bother to set a default value of 1. Each driver that cares about the
value of this field, will set it however they want.
