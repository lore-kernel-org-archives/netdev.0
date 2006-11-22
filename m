From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: [PATCH 2/4] NetXen: temp monitoring, newer firmware support, mm footprint reduction
Date: Wed, 22 Nov 2006 15:31:56 +0200
Message-ID: <20061122133156.GM4118@rhun.haifa.ibm.com>
References: <200611221321.kAMDLk7a009492@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:32497 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1755847AbWKVNcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 08:32:05 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kAMDW0m6067202
	for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 13:32:03 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAMDYmql2932982
	for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 13:34:48 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAMDVu8k003439
	for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 13:31:57 GMT
To: "Linsys Contractor Amit S. Kale" <amitkale@netxen.com>
Content-Disposition: inline
In-Reply-To: <200611221321.kAMDLk7a009492@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 22, 2006 at 05:21:46AM -0800, Linsys Contractor Amit S. Kale wrote:
> NetXen: 1G/10G Ethernet Driver updates
> 	- These fixes take care of driver on machines with >4G memory
> 	- Driver cleanup

It appears that you're implementing bounce buffering yourself - why?
if bounce buffering is necessary, the DMA-API implementation should
take care of this automatically (e.g., by using swiotlb).

Cheers,
Muli
