From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [DEBUG INFO]IPv6: sleeping function called from invalid
 context.
Date: Fri, 18 Nov 2005 09:47:21 +0900 (JST)
Message-ID: <20051118.094721.49574151.yoshfuji@linux-ipv6.org>
References: <437D23EB.4020204@21cn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751311AbVKRAqv@vger.kernel.org>
To: yanzheng@21cn.com
In-Reply-To: <437D23EB.4020204@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <437D23EB.4020204@21cn.com> (at Fri, 18 Nov 2005 08:44:27 +0800), Yan Zheng <yanzheng@21cn.com> says:

> I get follow message when switch to single user mode and the kernel version is 2.6.15-rc1-git5.
:
> Nov 18 08:26:23 localhost kernel: Debug: sleeping function called from invalid context at mm/slab.c:2472
> Nov 18 08:26:23 localhost kernel: in_atomic():1, irqs_disabled():0
> Nov 18 08:26:23 localhost kernel:  [<c0149d5a>] kmem_cache_alloc+0x5a/0x70
> Nov 18 08:26:23 localhost kernel:  [<e0f47336>] inet6_dump_fib+0xb6/0x110 [ipv6]

I remember someone replaced GFP_ATOMIC with GFP_KERNEL...

--yoshfuji
