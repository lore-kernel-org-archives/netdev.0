From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: Add netdev_dbg output for debugging
Date: Tue, 8 Aug 2017 08:39:38 -0500
Message-ID: <87dc8e60-049d-c289-fde9-7084ae621edc@linux.vnet.ibm.com>
References: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
 <1502119795.2219.21.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jallen@linux.vnet.ibm.com, tlfalcon@linux.vnet.ibm.com
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50949 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752051AbdHHNjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 09:39:43 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78DZxA9090490
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 09:39:42 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c7ay0xkwh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 09:39:42 -0400
Received: from localhost
        by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 8 Aug 2017 09:39:41 -0400
In-Reply-To: <1502119795.2219.21.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/2017 10:29 AM, Joe Perches wrote:
> On Mon, 2017-08-07 at 15:02 -0400, Nathan Fontenot wrote:
>> To ease debugging of the ibmvnic driver add a series of netdev_dbg()
>> statements to track driver status, especially during initialization,
>> removal, and resetting of the driver.
> 
> For some of the function entry logging, it seems
> better to use ftrace instead.
> 
>> diff --git a/drivers/net/ethernet/ibm/ibmvnic.c b/drivers/net/ethernet/ibm/ibmvnic.c
> []
>> @@ -389,6 +389,8 @@ static int init_stats_token(struct ibmvnic_adapter *adapter)
>>  	struct device *dev = &adapter->vdev->dev;
>>  	dma_addr_t stok;
>>  
>> +	netdev_dbg(adapter->netdev, "Initializing stats token\n");
> 
> here and subsequent.

Thanks for the tip. I'm not very familiar with ftrace so I'll have to
investigate and send a revised patch.

-Nathan 
