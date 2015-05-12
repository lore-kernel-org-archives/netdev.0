From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: RE: [PATCH v3 for-next 00/13] Add network namespace support in the
 RDMA-CM
Date: Tue, 12 May 2015 17:52:01 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373A8FD7B85@ORSMSX109.amr.corp.intel.com>
References: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>,
	Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11332 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933563AbbELRwD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 13:52:03 -0400
In-Reply-To: <1431253604-9214-1-git-send-email-haggaie@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Guy Shapiro (4):
>   IB/addr: Pass network namespace as a parameter
>   IB/ipoib: Return IPoIB devices matching connection parameters
>   IB/cma: Add support for network namespaces
>   IB/ucma: Take the network namespace from the process
> 
> Haggai Eran (8):
>   IB/core: Use SRCU when reading client_list or device_list
>   IB/cm: Reference count ib_cm_ids
>   IB/cm: API to retrieve existing listening CM IDs
>   IB/cm: Expose service ID in request events
>   IB/cma: Refactor RDMA IP CM private-data parsing code
>   IB/cma: Add compare_data checks to the RDMA CM module
>   IB/cma: Separate port allocation to network namespaces
>   IB/cma: Share CM IDs between namespaces
> 
> Yotam Kenneth (1):
>   IB/core: Find the network namespace matching connection parameters

How does network namespace support work with iWarp?
