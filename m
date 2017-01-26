From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net 2/5] ibmvnic: Fix MTU settings
Date: Thu, 26 Jan 2017 10:44:31 -0600
Message-ID: <783c7683-1cc2-6128-e19c-fd2c3c16cf4b@linux.vnet.ibm.com>
References: <1485378143-5084-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <1485378143-5084-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20170125.230504.215468934911959234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wvoigt@us.ibm.com,
        jallen@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org,
        nfont@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60288 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752821AbdAZQp1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:45:27 -0500
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0QGi9np063030
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 11:44:37 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
        by mx0a-001b2d01.pphosted.com with ESMTP id 286xt52evv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 11:44:37 -0500
Received: from localhost
        by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Thu, 26 Jan 2017 11:44:36 -0500
In-Reply-To: <20170125.230504.215468934911959234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 10:05 PM, David Miller wrote:
> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Date: Wed, 25 Jan 2017 15:02:20 -0600
>
>> In the current driver, the MTU is set to the maximum value
>> capable for the backing device. This patch sets the MTU to the
>> default value for a Linux net device.
> Why are you doing this?
>
> What happens to users who depend upon the current behavior.
>
> They will break, and that isn't acceptable.
>
The current behavior was already broken.  We were seeing firmware errors when sending jumbo sized packets .  We plan to add proper support for jumbo sized packets as soon as possible.  
