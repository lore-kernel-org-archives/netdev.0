From: Arvid Brodin <arvid.brodin@enea.com>
Subject: Re: bridge: HSR support
Date: Wed, 7 Dec 2011 00:23:21 +0100
Message-ID: <4EDEA3E9.3070004@enea.com>
References: <4E948A04.8060400@enea.com>	<20111011112821.28cd3e51@nehalam.linuxnetplumber.net>	<4E94D67A.9060207@enea.com>	<4EA5738B.8080008@enea.com>	<4EAACB7A.4090207@enea.com> <20111028175421.339b7c49@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:22315 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752089Ab1LFXX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 18:23:28 -0500
In-Reply-To: <20111028175421.339b7c49@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 28 Oct 2011 17:34:18 +0200
> Arvid Brodin <arvid.brodin@enea.com> wrote:
> 
>> Ok, so after a lot of reading and looking through code I have this idea of a
>> standalone solution:
>>
>> 1) Add ioctls to create (and remove) "hsr" netdevs which encapsulates two
>>    physical Ethernet interfaces each (somewhat like the bridge code does, but
>>    with precisely 2 interfaces slaved).
> 
> Please use the newer netlink interface and the master attribute for this
> rather than inventing yet another ioctl.


Is the rtnl interface documented anywhere (the usage of the different IFLA_
flags etc.)? Specifically: how do I use the IFLA_MASTER flag (what's the
meaning of the 32-bit data it wants, and how is it used by the kernel)? I 
haven't been very successful figuring this out by looking at the kernel code.


Also, how do I best tell the kernel which my slave devices are when creating
the hsr device? Should I create my own IFLA_HSR_UNSPEC, etc, or can I use some
of the generic flags?


Oh, and the kernel (struct rtnl_link_ops).newlink method has two (struct
nlattr *[]) params: tb and data. What are their roles?


-- 
Arvid Brodin
Enea Services Stockholm AB
