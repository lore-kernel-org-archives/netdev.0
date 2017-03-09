From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: fix linux/packet_diag.h userspace compilation
 error
Date: Thu, 09 Mar 2017 13:23:06 -0800 (PST)
Message-ID: <20170309.132306.2135023022720335742.davem@davemloft.net>
References: <20170307202802.GA19323@altlinux.org>
        <20170307.123535.1895338978981637855.davem@davemloft.net>
        <20170307205050.GB19323@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@virtuozzo.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170307205050.GB19323@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Tue, 7 Mar 2017 23:50:50 +0300

> Replace MAX_ADDR_LEN with its numeric value to fix the following
> linux/packet_diag.h userspace compilation error:
> 
> /usr/include/linux/packet_diag.h:67:17: error: 'MAX_ADDR_LEN' undeclared here (not in a function)
>   __u8 pdmc_addr[MAX_ADDR_LEN];
> 
> This is not the first case in the UAPI where the numeric value
> of MAX_ADDR_LEN is used instead of symbolic one, uapi/linux/if_link.h
> already does the same:
> 
> $ grep MAX_ADDR_LEN include/uapi/linux/if_link.h 
> 	__u8 mac[32]; /* MAX_ADDR_LEN */
> 
> There are no UAPI headers besides these two that use MAX_ADDR_LEN.
> 
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>

Applied and queued up for -stable.
