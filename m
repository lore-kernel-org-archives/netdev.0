From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Fri, 27 Jun 2003 08:45:19 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EFC668F.9010004@us.ibm.com>
References: <3EF9D5C2.5080101@us.ibm.com>	<20030625.234251.116353369.davem@redhat.com>	<3EFB2017.5030202@us.ibm.com> <20030626.230727.35666164.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030626.230727.35666164.davem@redhat.com>
List-Id: netdev.vger.kernel.org

rtnetlink_rcv_msg() calls dumpit() (via netlink_dump_start) only for those
messages for which the last two bits are binary '10'. So I had to use these
values. All the other *GET* macros use the same semantics.

thanks,

- KK


David S. Miller wrote:
>    From: Krishna Kumar <krkumar@us.ibm.com>
>    Date: Thu, 26 Jun 2003 09:32:23 -0700
> 
> I still have problems with this patch.
>    
>    -#define	RTM_MAX		(RTM_BASE+31)
>    +#define	RTM_GETLNKFLAGS	(RTM_BASE+34)
>    +
>    +#define	RTM_GETPLIST	(RTM_BASE+38)
> 
> Please allocate contiguous numbers to the new messages, don't skip
> around like this.
> 
> Thanks.  (this of course means you have to redo your 2.4.x patch
> as well)
> 

