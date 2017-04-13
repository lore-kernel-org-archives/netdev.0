From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next 4/8] net/ncsi: Add debugging infrastructurre
Date: Thu, 13 Apr 2017 15:11:12 +1000
Message-ID: <20170413051112.GA28206@gwshan>
References: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492051600-26706-5-git-send-email-gwshan@linux.vnet.ibm.com>
 <1492057706.28586.10.camel@perches.com>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        davem@davemloft.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53416 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751312AbdDMFMO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 01:12:14 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D58dES117018
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 01:12:13 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29snvjq7b4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 01:12:13 -0400
Received: from localhost
        by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 13 Apr 2017 15:12:10 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D5C1Tf47382760
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 15:12:09 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
        by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D5Bail011259
        for <netdev@vger.kernel.org>; Thu, 13 Apr 2017 15:11:37 +1000
Content-Disposition: inline
In-Reply-To: <1492057706.28586.10.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 12, 2017 at 09:28:26PM -0700, Joe Perches wrote:
>On Thu, 2017-04-13 at 12:46 +1000, Gavin Shan wrote:
>> This creates procfs directories as NCSI debugging infrastructure.
>> With the patch applied, We will see below procfs directories. Every
>> NCSI package and channel has one corresponding directory. Other than
>> presenting the NCSI topology, No real function has been achieved
>> through these procfs directories so far.
>
>/proc is meant to be stable.
>
>Why not use debugfs?
>

Joe, thanks for the comment. I think debugfs makes more sense than
procfs in this case. I will use it in next respin. The directory
structure won't change, meaning /sys/kernel/debug/ncsi/ will be
created.

>>      /proc/ncsi/eth0
>>      /proc/ncsi/eth0/p0
>>      /proc/ncsi/eth0/p0/c0
>>      /proc/ncsi/eth0/p0/c1
>

Thanks,
Gavin
