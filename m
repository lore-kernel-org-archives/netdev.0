From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next RFC 0/5] xen-netback: TX grant mapping instead
 of copy
Date: Tue, 5 Nov 2013 17:01:15 +0000
Message-ID: <5279245B.6070202@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com> <1383303035.672.29.camel@kazak.uk.xensource.com> <5273FA37.6020903@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5273FA37.6020903@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/11/13 19:00, Zoltan Kiss wrote:
>  >> Based on my investigations the packet get only copied if it is
> delivered to
>  >>Dom0 stack, which is due to this patch:
>  >>https://lkml.org/lkml/2012/7/20/363
>  >>That's a bit unfortunate, but as far as I know for the huge majority
> this use
>  >>case is not too important.
>> Likely to be true, but it would still be interesting to know how badly
>> this use case suffers with this change, and any increase in CPU usage
>> would be interesting to know about as well.
> I can't find my numbers, but as far as I remember it wasn't
> significantly worse than grant copy. I will check that again.
I've measured it now: with my patch it was 5.2 Gbps, without it 5.4. 
Both cases iperf in Dom0 maxed out its CPU, mostly in soft interrupt 
context, based on top.

Zoli
