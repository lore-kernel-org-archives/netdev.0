From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH net-next v2 1/1] geneve: add rtnl changelink support
Date: Wed, 19 Jul 2017 20:08:47 -0700
Message-ID: <4cd3c389-f231-1407-5a7d-7e4df51a8c05@oracle.com>
References: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
 <20170719.165116.1585585461311289445.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37472 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbdGTDI5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 23:08:57 -0400
In-Reply-To: <20170719.165116.1585585461311289445.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 4:51 PM, David Miller wrote:
> From: Girish Moodalbail <girish.moodalbail@oracle.com>
> Date: Tue, 18 Jul 2017 16:33:06 -0700
> 
>> +static inline bool geneve_dst_addr_equal(struct ip_tunnel_info *a,
>   ...
>> +static inline void geneve_quiesce(struct geneve_dev *geneve,
>   ...
>> +static inline void geneve_unquiesce(struct geneve_dev *geneve,
> 
> Please no inline functions in foo.c files, let the compiler
> decide.

Sure thing. Will do.

regards,
~Girish

> 
> Thanks.
> 
