From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: [PATCH] anycast support for IPv6, updated to 2.5.44
Date: Thu, 20 Mar 2003 12:01:36 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030320.120136.108400165.yoshfuji@wide.ad.jp>
References: <OFC909BFEE.F581E26E-ON88256C60.0072A662@boulder.ibm.com>
	<20030319.163105.44963500.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: davem@redhat.com
In-Reply-To: <20030319.163105.44963500.davem@redhat.com>
List-Id: netdev.vger.kernel.org

In article <20030319.163105.44963500.davem@redhat.com> (at Wed, 19 Mar 2003 16:31:05 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

>    From: "David Stevens" <dlstevens@us.ibm.com>
>    Date: Mon, 28 Oct 2002 14:06:00 -0700
>    
>    Below is a patch to add anycast support for IPv6. It's the same patch as
>    I've posted previously, but updated with comments from Chris Hellwig and
>    for kernel version 2.5.44.
> 
> I'm going to apply this, with the small change that dev_getany() is
> renamed to dev_get_by_flags() which more accurately describes
> what the routine does.

Again: I don't like API at all.

Anycast address management itself in that patch would be ok.
However, JOIN/LEAVE is NOT useful and userland application will be 
incompatible with other implementation. (sigh...)
I think linux likes unicast model (assign address like unicast address), too.

And, we see __constant_{hton,ntoh}{l,h}() again...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
