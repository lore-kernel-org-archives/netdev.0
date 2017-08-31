From: Andrii <tulup@mail.ru>
Subject: Re: [PATCH] net: dccp: Add handling of IPV6_PKTOPTIONS to
 dccp_v6_do_rcv()
Date: Thu, 31 Aug 2017 08:27:18 +0300
Message-ID: <171ec313-e9f4-9eca-d881-add54934a5bd@mail.ru>
References: <20170830090435.58406d1b@dev>
 <20170830.221649.818214075248119092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, dccp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170830.221649.818214075248119092.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'll fix and re-send. Thanks.


On 8/31/2017 8:16 AM, David Miller wrote:
> From: Andrii Vladyka <tulup@mail.ru>
> Date: Wed, 30 Aug 2017 09:04:35 +0300
>
>> +	if (opt_skb)
>                      ^^^^
>
> Trailing whitespace.
>
>> @@ -653,6 +647,36 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
>>   		__kfree_skb(opt_skb);
>>   	kfree_skb(skb);
>>   	return 0;
>> +	
>     ^^^^^^^
>
> Likewise.
