From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Tue, 12 Jul 2016 11:11:16 -0700 (PDT)
Message-ID: <20160712.111116.1765805486132601360.davem@davemloft.net>
References: <alpine.LFD.2.20.1607081340430.26593@stoner.jakma.org>
	<20160708.184129.1545084362199727100.davem@davemloft.net>
	<SN1PR0201MB1807CF3E6A28E344EE2E41F0F9300@SN1PR0201MB1807.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul@jakma.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Alan.Davey@metaswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGLSLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:11:18 -0400
In-Reply-To: <SN1PR0201MB1807CF3E6A28E344EE2E41F0F9300@SN1PR0201MB1807.namprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Davey <Alan.Davey@metaswitch.com>
Date: Tue, 12 Jul 2016 12:34:07 +0000

> -  all future applications have to continue to implement their own fragmentation code, duplicating that which already exists in the kernel

They have to do this anyways, don't you see this?

Otherwise they don't support %99 of the kernels out there.

Even if I put this change in now, it would take years for it to
propagate to even a moderate percentage of Linux machines out there.

And applications doing a "we only support kernels > version x.y.z" is
a situation I don't want to promote if you think that's a reasonable
way to handle this.
