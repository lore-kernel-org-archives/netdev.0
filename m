From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: define __packed for the userspace code
Date: Sun, 22 Aug 2010 21:16:05 -0700 (PDT)
Message-ID: <20100822.211605.02288279.davem@davemloft.net>
References: <20100822.183624.28802617.davem@davemloft.net>
	<AANLkTikBcuYa_HNzhYYG62CLjcfptQNQM_zOsv9fXRfS@mail.gmail.com>
	<20100822.193609.35028164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100822.193609.35028164.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 22 Aug 2010 19:36:09 -0700 (PDT)

> From: Changli Gao <xiaosuo@gmail.com>
> Date: Mon, 23 Aug 2010 10:29:49 +0800
> 
>> Do you mean that use the __attribute__((packed)) annotation in all of
>> these files:
>> 
>> localhost linux # grep "\<__packed\>" usr/include/ -r | uniq
>> usr/include/linux/if_hippi.h:} __packed;
>> usr/include/linux/if_fddi.h:} __packed;
>> usr/include/linux/nbd.h:} __packed;
>> usr/include/linux/ncp.h:} __packed;
>> usr/include/linux/rfkill.h:} __packed;
>> usr/include/linux/if_pppox.h:} __packed;
>> usr/include/linux/phonet.h:} __packed;
>> usr/include/linux/ipv6.h:} __packed;    /* required for some archs */
>> usr/include/linux/ipv6.h:} __packed;
>> usr/include/linux/if_ether.h:} __packed;
> 
> It seems so, yes.

Changli I applied your patch to convert these __packed tags back to
the original expansion.

Thanks!
