From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Fri, 28 Oct 2016 00:10:32 +0200
Message-ID: <87funhv3xj.fsf@redhat.com>
References: <20161027.112525.2290598329610980726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20161027.112525.2290598329610980726.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2016 at 03:25 PM GMT, David Miller wrote:
> From: Jakub Sitnicki <jkbs@redhat.com>
> Date: Mon, 24 Oct 2016 11:28:52 +0200
>
>> +	inner_iph = skb_header_pointer(
>> +		skb, skb_transport_offset(skb) + sizeof(*icmph),
>> +		sizeof(_inner_iph), &_inner_iph);
>
> Please do not style this call like this, put as many arguments as
> you can on the first line.
>
> 	inner_iph = skb_header_pointer(skb,
> 				       skb_transport_offset(skb) + sizeof(*icmph),
> 				       sizeof(_inner_iph), &_inner_iph);
>
> And on the second and subsequent lines, indent to the first column after
> the openning parenthesis of the first line.

FWIW, I had it styled like that and then changed it. Will change back.

In my defense - checkpatch.pl made me do it, Your Honor! (line too long)
