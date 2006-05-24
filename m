From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 8/9] [I/OAT] Add a sysctl for tuning the I/OAT offloaded
 I/O threshold
Date: Tue, 23 May 2006 18:02:53 -0700
Message-ID: <20060523180253.5d28649f.akpm@osdl.org>
References: <20060524001653.19403.31396.stgit@gitlost.site>
	<20060524002021.19403.15607.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42387 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932106AbWEXBDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 21:03:15 -0400
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060524002021.19403.15607.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> Any socket recv of less than this ammount will not be offloaded
> 
>  Signed-off-by: Chris Leech <christopher.leech@intel.com>
>  ---
> 
>   include/linux/sysctl.h     |    1 +
>   include/net/tcp.h          |    1 +
>   net/core/user_dma.c        |    4 ++++
>   net/ipv4/sysctl_net_ipv4.c |   10 ++++++++++
>   4 files changed, 16 insertions(+), 0 deletions(-)
> 

Documentation/networking/ip-sysctl.txt too, please.
