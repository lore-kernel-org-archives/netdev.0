From: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Subject: Re: [PATCH v2] net:Add sysctl_tcp_sg_max_skb_frags
Date: Mon, 1 Feb 2016 14:12:36 +0100
Message-ID: <56AF59C4.1000807@oracle.com>
References: <568F87AC.60405@oracle.com>
 <1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
 <1453907702.20722.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <56A9087C.20305@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Haakon Bugge <haakon.bugge@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56A9087C.20305@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/27/2016 07:12 PM, Hannes Frederic Sowa wrote:
> On 27.01.2016 16:15, Eric Dumazet wrote:
>>
>> If it is a common one, it should be /proc/sys/net/core/... instead
>> of /proc/sys/net/ipv4/tcp_....
> >
>> Other providers include :
>>
>> 1) GRO stack
>> 2) callers of sock_alloc_send_pskb(), alloc_skb_with_frags(),
>> sock_alloc_send_skb() ..
>
> I agree, this knob should get a generic name and live in a generic 
> net/ directory to control this globally, so things don't break during 
> forwarding etc.
>
> It does not solve the problem completely, e.g. when VMs send gso 
> packets through a vhost-net onto IPoIB, no?
>
> Thanks,
> Hannes
>
I have understood more of the problem Hannes raises and I realize that 
we need a slowpath in IPoIB to handle the problem
in question. I will make a new version of this patch with a more correct 
position/name of the sysctl-variable.
I'll also make a separate patch adding the slowpath i IPoIB.

Hans
