From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Tue, 19 Jan 2010 15:06:01 -0500
Message-ID: <4B5610A9.7030902@majjas.com>
References: <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com>
 <20100118212516.GE3157@del.dom.local> <4B54D50C.90608@majjas.com>
 <20100118220814.GG3157@del.dom.local> <20100118221747.GH3157@del.dom.local>
 <4B54E4EF.8080602@majjas.com> <4B554730.6090000@majjas.com>
 <20100119104739.GA9088@ff.dom.local> <4B55D40F.5080509@majjas.com>
 <20100119195933.GA3060@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754820Ab0ASUHA@vger.kernel.org>
In-reply-to: <20100119195933.GA3060@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/19/2010 2:59 PM, Jarek Poplawski wrote:
> On Tue, Jan 19, 2010 at 10:47:27AM -0500, Michael Breuer wrote:
> ...
>    
>> Still get the warning... but now 60 bytes.
>> Jan 19 10:43:50 mail kernel: ------------[ cut here ]------------
>> Jan 19 10:43:50 mail kernel: WARNING: at lib/dma-debug.c:902
>>      
> Thanks for trying this.
> Jarek P.
>    
NP. Let me know what else I can do to help with this one. Note that it 
seems innocuous. I'll continue with the older set and no dmar for now 
and see if I get another crash.
