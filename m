From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: Correct return code checking for
 ibmvnic_init during probe
Date: Wed, 21 Jun 2017 14:48:06 -0500
Message-ID: <199365a2-50ce-1d16-8192-0eb4157c215f@linux.vnet.ibm.com>
References: <20170620212154.46216.80460.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
 <20170621.153936.1668683376357645391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54870 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751083AbdFUTsK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:48:10 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LJheGO018059
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:48:10 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b7p1knmda-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:48:09 -0400
Received: from localhost
        by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Wed, 21 Jun 2017 13:48:09 -0600
In-Reply-To: <20170621.153936.1668683376357645391.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/21/2017 02:39 PM, David Miller wrote:
> From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
> Date: Tue, 20 Jun 2017 17:21:54 -0400
> 
>> Fixes: 6a2fb0e99f9c (ibmvnic: driver initialization for kdump/kexec)
> 
> I'm incredibly curious where you got the idea to put the Fixes: tag
> at the beginning of the commit message.

I have no excuse. As you mentioned I should have looked at what others
had done when using the Fixes.

Would you like me to re-send with the Fixes tag corrected?

-Nathan

> 
> Have you seen anyone else submitting patches on netdev do this?
> 
> It helps to operate by example, and look at how other people do
> things.
> 
> The correct location for the Fixes: tag is at the beginning of the
> singoffs and acks at the end of the commit message.
> 
> There shall be no empty lines between the Fixes: tag and those
> signoffs and acks.
> 
> Thank you.
> 
