From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next v2 1/2] mpls: allow TTL propagation to IP packets
 to be configured
Date: Fri, 10 Mar 2017 10:12:10 +0000
Message-ID: <dfc89022-10d9-6f2b-9aef-ceadfe360a56@brocade.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-2-git-send-email-rshearma@brocade.com>
 <d23fe5a5-3f8e-4bc7-dbb1-af33de7a5e41@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:55736 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933511AbdCJKM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 05:12:29 -0500
In-Reply-To: <d23fe5a5-3f8e-4bc7-dbb1-af33de7a5e41@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/17 02:40, David Ahern wrote:
> On 3/7/17 5:46 PM, Robert Shearman wrote:
>> diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
>> index d29203651c01..58e0e46c4a5c 100644
>> --- a/include/net/netns/mpls.h
>> +++ b/include/net/netns/mpls.h
>> @@ -10,7 +10,9 @@ struct ctl_table_header;
>>
>>  struct netns_mpls {
>>  	size_t platform_labels;
>> +	int ip_ttl_propagate;
>>  	struct mpls_route __rcu * __rcu *platform_label;
>> +
>>  	struct ctl_table_header *ctl;
>>  };
>>
>
> I'd prefer the platform_labels stay with platform_label. ie., put the
> new ip_ttl_propagate above platform_labels.
>

Ok, will do in v3.

Thanks,
Rob
