From: Santiago Leon <santil@us.ibm.com>
Subject: Re: [PATCH] ibmveth change buffer pools dynamically
Date: Fri, 28 Apr 2006 16:53:28 -0500
Message-ID: <44528ED8.7070402@us.ibm.com>
References: <1145981998.16266.5.camel@santilt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:8335 "EHLO e34.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751457AbWD1Vzl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 17:55:41 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k3SLteOX008986
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 17:55:40 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3SLteIH172316
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:55:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k3SLtet1020863
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 15:55:40 -0600
To: jgarzik@pobox.com, netdev@vger.kernel.org
In-Reply-To: <1145981998.16266.5.camel@santilt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Santiago Leon wrote:

> This patch provides a sysfs interface to change some properties of the
> ibmveth buffer pools (size of the buffers, number of buffers per pool,
> and whether a pool is active).  Ethernet drivers use ethtool to provide
> this type of functionality.  However, the buffers in the ibmveth driver
> can have an arbitrary size (not only regular, mini, and jumbo which are
> the only sizes that ethtool can change), and also ibmveth can have an
> arbitrary number of buffer pools 
> 
> Under heavy load we have seen dropped packets which obviously kills TCP
> performance.  We have created several fixes that mitigate this issue,
> but we definitely need a way of changing the number of buffers for an
> adapter dynamically.  Also, changing the size of the buffers allows
> users to change the MTU to something big (bigger than a jumbo frame)
> greatly improving performance on partition to partition transfers.
> 
> The patch creates directories pool1...pool4 in the device directory in
> sysfs, each with files: num, size, and active (which default to the
> values in the mainline version).
> 
> Comments and suggestions are welcome...
> 

Jeff, if you don't have any problem with this patch, can you apply it?

Thanks,

-- 
Santiago A. Leon
Power Linux Development
IBM Linux Technology Center

