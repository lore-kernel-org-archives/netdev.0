From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH next] s390_net: Kill directly reference of netdev->priv
Date: Tue, 09 Dec 2008 13:57:11 +0100
Message-ID: <AB3A303572A710393B461DD8@L3k9049.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:48177 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbYLIM5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 07:57:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 05 Dec 2008 23:09:55 +0800

> The private data comes from ccwgroup_device.
> So just don't allocate private data memory when do alloc_netdev()
> and use netdev->ml_priv to reference private data.
>
> Not do compile-test. Because have no s390 box.
>
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
Acked-by: Ursula Braun <ursula.braun@de.ibm.com>

We run an additional test on our s390 box. Thanks!


