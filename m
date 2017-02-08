From: David Miller <davem@davemloft.net>
Subject: Re: KASAN+netlink, was: [PATCH] [net-next?] hns: avoid stack
 overflow with CONFIG_KASAN
Date: Wed, 08 Feb 2017 11:27:16 -0500 (EST)
Message-ID: <20170208.112716.1778159455570583655.davem@davemloft.net>
References: <20170203163607.3488037-1-arnd@arndb.de>
        <20170206.120318.1268240226202516488.davem@davemloft.net>
        <4910112.l20yySyWnA@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
        linux-kernel@vger.kernel.org, a.ryabinin@samsung.com,
        johannes.berg@intel.com, nikolay@cumulusnetworks.com,
        nicolas.dichtel@6wind.com, adobriyan@gmail.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4910112.l20yySyWnA@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 08 Feb 2017 13:03:59 +0100

> Things I've tried here are:
> 
> - Moving nla_put_{u8,u16,u32} out of line is probably uncontroversial and
>   it helps enough with br_netlink.c, but nl820211 is worse and needs some
>   additional fiddling.

This is probably the least intrusive solution if it works.
