From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Sat, 28 Jun 2003 13:06:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030628.130602.63704890.yoshfuji@linux-ipv6.org>
References: <20030626.230727.35666164.davem@redhat.com>
	<3EFC668F.9010004@us.ibm.com>
	<20030627.144752.78715628.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030627.144752.78715628.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030627.144752.78715628.davem@redhat.com> (at Fri, 27 Jun 2003 14:47:52 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

>    From: Krishna Kumar <krkumar@us.ibm.com>
>    Date: Fri, 27 Jun 2003 08:45:19 -0700
> 
>    rtnetlink_rcv_msg() calls dumpit() (via netlink_dump_start) only
>    for those messages for which the last two bits are binary '10'. So
>    I had to use these values. All the other *GET* macros use the same
>    semantics.
> 
> Ok, please retransmit your two patches (2.4.x and 2.5.x) to me
> under seperate cover.  I don't keep a copy around of patches
> I've decided not to apply.

Well...

1. is it okay to have another hook for garbbig prefix list?
   Userspace application can get such information via
   - routing table
   - interface flag

2. is the "managed" flags etc, which is per interface variable, 
   really NEWROUTE information?
   It is NOT L2 thing, but it is per-link information.
   I think it is NEWLINK thing.

What I'm thinking is:

 - fix "ADDRCONF" flag in route information
 - manage / other flags via NEWLINK message
(- No new interface to get prefix itself.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
