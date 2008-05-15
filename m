From: "Kingsley Foreman" <kingsley@internode.com.au>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface
Date: Thu, 15 May 2008 19:36:54 +0930
Message-ID: <8ECDBB4EB5394859BFFACAAEE3A6EDB0@uglypunk>
References: <20080515091216.GA6550@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757484AbYEOKHd@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

i just rolled back the kernel to 2.6.24 and im seeing the same thing,

I was using 2.6.22 before and didn't see the problem, txqueuelen on the 
bond0 interface is 0 (the default)

--------------------------------------------------
From: "Jarek Poplawski" <jarkao2@gmail.com>
Sent: Thursday, May 15, 2008 6:42 PM
To: "Kingsley Foreman" <kingsley@internode.com.au>
Cc: "Eric Dumazet" <dada1@cosmosbay.com>; "Andrew Morton" 
<akpm@linux-foundation.org>; <linux-kernel@vger.kernel.org>; 
<netdev@vger.kernel.org>
Subject: Re: NET_SCHED cbq dropping too many packets on a bonding interface

> On 15-05-2008 08:16, Kingsley Foreman wrote:
> ...
>>>>> Ive been using qdisc for quite a while without any problems,
>>>>> I just rebuilt a gentoo box with 2.6.25 kernel that does a lot of
>>>>> traffic
>>>>> ~1000mbits+ over a bonded interface
>>>>>
>>>>> Im however seeing a big problem with cbq class dropping packets for no
>>>>> reason i can see, and it is causing a lot of speed issues.
> ...
>
> Do you mean the same box with the same config but the previous kernel
> (2.6.24) doesn't show this problem? BTW, what is txqueuelen on this
> bond0?
>
> Regards,
> Jarek P.
> 
