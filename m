From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Fri, 27 Jun 2008 19:33:40 -0700 (PDT)
Message-ID: <20080627.193340.51998365.davem@davemloft.net>
References: <20080619.144621.120746379.davem@davemloft.net>
	<485ADFDF.1070509@free.fr>
	<485BADF3.10704@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bpidoux@free.fr, ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: f6bvp@free.fr
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <485BADF3.10704@free.fr>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Date: Fri, 20 Jun 2008 15:17:39 +0200

> The second solution is to declare a new structure
> 
> * new ax25 info struct */
> struct ax25_info_long_timers_struct {
 ...
> 
> adding another case SIOCAX25GETNEWINFO
> that would be defined
> #define SIOCAX25GETNEWINFO         (SIOCPROTOPRIVATE+14)
> 
> and trigger warning message by calls to SIOCAX25GETINFOOLD and
> SIOCAX25GETINFO.
> 
> It that the right way to do it ?

Yes.
