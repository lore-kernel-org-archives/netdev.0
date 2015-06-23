From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: Re: [PATCH net-next V11 2/3] Check for vlan ethernet types for 8021.q
 or 802.1ad
Date: Tue, 23 Jun 2015 15:01:37 -0400
Message-ID: <5589AD11.1060009@gmail.com>
References: <1435083990-12986-1-git-send-email-thomasfherbert@gmail.com> <1435083990-12986-3-git-send-email-thomasfherbert@gmail.com> <5589A8C8.6080702@cogentembedded.com>
Reply-To: thomasfherbert@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: therbert@redhat.com, dev@openvswitch.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:34125 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754761AbbFWTBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 15:01:40 -0400
Received: by yhnv31 with SMTP id v31so7675039yhn.1
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 12:01:39 -0700 (PDT)
In-Reply-To: <5589A8C8.6080702@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/23/15 2:43 PM, Sergei Shtylyov wrote:
> Hello.
>
> On 06/23/2015 09:26 PM, Thomas F Herbert wrote:
>
>> Signed-off-by: Thomas F Herbert <thomasfherbert@gmail.com>
> [...]
>
>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>> index 920e445..3713454 100644
>> --- a/include/linux/if_vlan.h
>> +++ b/include/linux/if_vlan.h
>> @@ -627,5 +627,14 @@ static inline netdev_features_t
>> vlan_features_check(const struct sk_buff *skb,
>>
>>       return features;
>>   }
>> +/**
>> + * Check for legal valid vlan ether type.
>
>     The comment doesn't follow the kernel-doc format determined by /**.
OK, I will change it to the proper kernel doc format.
>
>> + */
>> +static inline bool eth_type_vlan(__be16 ethertype)
>> +{
>> +    if (ethertype == htons(ETH_P_8021Q) || ethertype ==
>> htons(ETH_P_8021AD))
>> +        return true;
>> +    return false;
>
>     Perhaps *switch*?
I have no objection to changing this to a switch statement.
>
> [...]
>
> WBR, Sergei
>


-- 
Thomas F. Herbert
