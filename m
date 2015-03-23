From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [PATCH] net: tcp6: fix double call of tcp_v6_fill_cb()
Date: Mon, 23 Mar 2015 18:50:53 +0300
Message-ID: <5510365D.6070109@oracle.com>
References: <1427107090-4100-1-git-send-email-alexey.kodanev@oracle.com> <1427121492.25985.68.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427121492.25985.68.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,
On 03/23/2015 05:38 PM, Eric Dumazet wrote:
> On Mon, 2015-03-23 at 13:38 +0300, Alexey Kodanev wrote:
> \
>> @@ -1538,7 +1525,7 @@ do_time_wait:
>>   					    &ipv6_hdr(skb)->saddr, th->source,
>>   					    &ipv6_hdr(skb)->daddr,
>>   					    ntohs(th->dest), tcp_v6_iif(skb));
>> -		if (sk2 != NULL) {
>> +		if (sk2) {
>>   			struct inet_timewait_sock *tw = inet_twsk(sk);
>>   			inet_twsk_deschedule(tw, &tcp_death_row);
>>   			inet_twsk_put(tw);
> And please refrain adding such cleanup changes in a bug fix.

Sure, I will. Thank you for review!

Best regards,
Alexey

> Thanks !
>
>
