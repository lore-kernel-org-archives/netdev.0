From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 13 Jan 2010 15:39:37 -0500
Message-ID: <4B4E2F89.2050606@majjas.com>
References: <4B4625BD.3070202@majjas.com> <20100107183545.GA3208@del.dom.local>
 <4B462B3C.90506@majjas.com> <20100107185040.GB3208@del.dom.local>
 <4B466A26.5070506@majjas.com> <20100108074539.GA6205@ff.dom.local>
 <4B475FF9.7000702@majjas.com> <20100108212923.GA3078@del.dom.local>
 <4B47A81B.5040601@majjas.com> <4B4809EF.1070609@majjas.com>
 <20100109122830.GA4386@del.dom.local> <4B48CC2C.2090403@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755134Ab0AMUkq@vger.kernel.org>
In-reply-to: <4B48CC2C.2090403@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/9/2010 1:34 PM, Michael Breuer wrote:
> On 1/9/2010 7:28 AM, Jarek Poplawski wrote:   ...
>> It looks like DMAR is the main candidate for a new linux-kernel@ or
>> bugzilla bug report. You should also consider reporting these ipv6
>> problems, especially if you think they can trigger TX timeouts. (In
>> both cases it would be good to try current mainline first, when you
>> get it workable.)
> Ok - I'll get onto mainline and then deal with DMAR.
Just an FYI - 2.6.32.3 with alt 3 af_packet patch & sky2 pskb_may_pull 
runs OK with DMAR (re)enabled and msi enabled.
>> Thanks,
>> Jarek P.
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
