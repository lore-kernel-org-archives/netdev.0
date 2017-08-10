From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net] geneve: maximum value of VNI cannot be used
Date: Thu, 10 Aug 2017 08:58:58 -0700
Message-ID: <0724a580-49c0-a457-802c-40fde8d040d5@oracle.com>
References: <1502238384-14440-1-git-send-email-girish.moodalbail@oracle.com>
 <20170809.224130.1529052203716251519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43692 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751914AbdHJP7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 11:59:08 -0400
In-Reply-To: <20170809.224130.1529052203716251519.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/17 10:41 PM, David Miller wrote:
> From: Girish Moodalbail <girish.moodalbail@oracle.com>
> Date: Tue,  8 Aug 2017 17:26:24 -0700
> 
>> Geneve's Virtual Network Identifier (VNI) is 24 bit long, so the range
>> of values for it would be from 0 to 16777215 (2^24 -1).  However, one
>> cannot create a geneve device with VNI set to 16777215. This patch fixes
>> this issue.
>>
>> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> 
> I always worry that someone, somewhere, might be using this in some
> way and this will break things.
> 
> But I'll apply this for now.
> 
Thanks David. As per the output of 'ip link help geneve', 16777215 is a valid 
value. However, due to incorrect check in the kernel that value was not supported.

$ ip link help geneve |egrep -A1 VNI
Usage: ... geneve id VNI
                   remote ADDR
