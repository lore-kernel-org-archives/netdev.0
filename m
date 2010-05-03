From: Vivek Kashyap <kashyapv@us.ibm.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support
 for enic dynamic vnics
Date: Mon, 3 May 2010 09:18:57 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005030817210.5203@vk>
References: <C7FEE68A.2CBEF%scofeldm@cisco.com> <201004291748.38702.arnd@arndb.de> <alpine.LFD.2.00.1005022119140.16925@vk> <201005031332.34955.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:55745 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803Ab0ECQT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 12:19:58 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o43GGpFn002764
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 10:16:51 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o43GJkhQ082732
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 10:19:47 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o43GJihP015141
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 10:19:45 -0600
In-Reply-To: <201005031332.34955.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Yes, that's exactly what I wrote. So do you have any idea why we would
> ever not want to do the resource reservation?

I agree that resource reservation is preferable during migration since it 
avoids failure due to lack of resources at the switch (after doing all the 
work of state transfer to the target system).

In other scenarios where the period of resource reservation is long, 
thereby diminishing the number of active vsi flows, the management 
entity might choose not to use resource reservation.

Vivek

>
> 	Arnd
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
