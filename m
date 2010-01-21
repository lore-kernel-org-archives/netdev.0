From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Thu, 21 Jan 2010 14:48:57 -0500
Message-ID: <4B58AFA9.1000600@majjas.com>
References: <20100118073018.GA6270@ff.dom.local> <4B548C6B.10607@majjas.com>
 <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com>
 <20100118212516.GE3157@del.dom.local> <4B54D50C.90608@majjas.com>
 <20100118220814.GG3157@del.dom.local> <20100118221747.GH3157@del.dom.local>
 <4B54E4EF.8080602@majjas.com> <4B554730.6090000@majjas.com>
 <20100119084120.GA6366@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754986Ab0AUTtR@vger.kernel.org>
In-reply-to: <20100119084120.GA6366@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/19/2010 3:41 AM, Jarek Poplawski wrote:
> On Tue, Jan 19, 2010 at 12:46:24AM -0500, Michael Breuer wrote:
>    
>> So net-net, as far as my TX packet loss issue, sky2 is in the clear. If
>> something on the linux side should be informing the switch about
>> something then there may still be an issue. If the wifi router should be
>> doing something differently, then it's unfortunately likely a 2.4.37
>> kernel issue (That's what dd-wrt is using).
>>      
> IMHO until there is no proof from a sniffer or some regs dumps the
> switch and the router are more suspicious than your NIC or linux box.
> Then debugging these other things isn't so much interesting from my
> POV ;-)
>
> Anyway, if you only want to get it working (instead of debugging),
> it seems you might try moving the dhcp server to the router or maybe
> even using two separate servers with their pools - unless I missed
> something in your config.
>
> Jarek P.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>    
Postscript: HP has confirmed that the 1400-8g switch doesn't work, 
"well," in a mixed 100Mb/1000Mb environment, and is dropping DHCP packets.
