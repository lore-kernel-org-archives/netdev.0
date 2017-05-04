From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 04/10] net/ncsi: Ethtool operation to get
 NCSI topology
Date: Thu, 4 May 2017 16:17:28 +1000
Message-ID: <20170504061728.GB2162@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1493786681-27468-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503222111.749ce90b@xeon-e3>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39969 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751195AbdEDGSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 02:18:32 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v446Djn4093927
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 02:18:31 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2a7dbjmfm0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 02:18:31 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 16:18:28 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v446IHUg197046
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 16:18:25 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
        by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v446Hqal013058
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 16:17:52 +1000
Content-Disposition: inline
In-Reply-To: <20170503222111.749ce90b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 10:21:11PM -0700, Stephen Hemminger wrote:
>On Wed,  3 May 2017 14:44:35 +1000
>Gavin Shan <gwshan@linux.vnet.ibm.com> wrote:
>
>> +void ncsi_ethtool_register_dev(struct net_device *dev)
>> +{
>> +	struct ethtool_ops *ops;
>> +
>> +	ops = (struct ethtool_ops *)(dev->ethtool_ops);
>> +	if (!ops)
>> +		return;
>> +
>> +	ops->get_ncsi_channels = ncsi_get_channels;
>> +}
>> +
>
>Instead of casting away const which opens up potential security
>issues. Have two ethtool_ops structures.
>

Thanks for the comments, Stephen. Yeah, It should be corrected
as Andrew already suggested.

Cheers,
Gavin
