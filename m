From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Fri, 21 Apr 2017 12:33:09 +1000
Message-ID: <20170421023309.GA3819@gwshan>
References: <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170420.132103.454438573956782815.davem@davemloft.net>
 <20170420233812.GA7223@gwshan>
 <20170420.175858.1747890177363276280.davem@davemloft.net>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gwshan@linux.vnet.ibm.com, netdev@vger.kernel.org, joe@perches.com,
        kubakici@wp.pl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48815 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1034770AbdDUCeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 22:34:19 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3L2YGSp121574
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 22:34:18 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29y0hdvapj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 22:34:18 -0400
Received: from localhost
        by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Fri, 21 Apr 2017 12:34:09 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
        by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3L2Xwpq1769772
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:34:06 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
        by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3L2XYcO016941
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:33:34 +1000
Content-Disposition: inline
In-Reply-To: <20170420.175858.1747890177363276280.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 05:58:58PM -0700, David Miller wrote:
>From: Gavin Shan <gwshan@linux.vnet.ibm.com>
>Date: Fri, 21 Apr 2017 09:38:12 +1000
>
>> (1) ethtool usually dumps statistics collected by hardware, but this
>> debugfs file dumps the statistics of packets seen (collected) by
>> software.
>
>ethtool is not strictly for hardware statistics, it's often used for
>software maintained values
>

Thanks for the confirm. I'll move the functionalities introduced by
this patchset to ethtool in next respin, as discussed in another
thread.

Cheers,
Gavin
