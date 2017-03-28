From: Kris Murphy <kriskend@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] openvswitch: Add missing case OVS_TUNNEL_KEY_ATTR_PAD
Date: Tue, 28 Mar 2017 10:22:32 -0500
Message-ID: <afef481c-1e03-3cce-dbd8-4cdb192596f0@linux.vnet.ibm.com>
References: <1b8ba07efdee3db310d4504462924565684ebd64.1489677257.git.kriskend@linux.vnet.ibm.com>
 <1489679488-18874-1-git-send-email-kriskend@linux.vnet.ibm.com>
 <20170316.120028.1195095010958027326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, seroyer@linux.vnet.ibm.com,
        adreznec@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:50591 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751318AbdC1PWq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:22:46 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2SFE65N069741
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 11:22:44 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29fsu1akeg-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 11:22:44 -0400
Received: from localhost
        by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <kriskend@linux.vnet.ibm.com>;
        Tue, 28 Mar 2017 09:22:42 -0600
In-Reply-To: <20170316.120028.1195095010958027326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue exists starting with 4.6 so can you add cc: 
Stable@vger.kernel.org #4.6+


On 3/16/2017 2:00 PM, David Miller wrote:
> From: Kris Murphy <kriskend@linux.vnet.ibm.com>
> Date: Thu, 16 Mar 2017 10:51:28 -0500
>
>> Added a case for OVS_TUNNEL_KEY_ATTR_PAD to the switch statement
>> in ip_tun_from_nlattr in order to prevent the default case
>> returning an error.
>>
>> Fixes: b46f6ded906e ("libnl: nla_put_be64(): align on a 64-bit area")
>> Signed-off-by: Kris Murphy <kriskend@linux.vnet.ibm.com>
> Applied and queued up for -stable, thanks.
>
