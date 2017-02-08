From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: KASAN+netlink, was: [PATCH] [net-next?] hns: avoid stack
 overflow with CONFIG_KASAN
Date: Wed, 08 Feb 2017 13:24:25 +0100
Message-ID: <1486556665.24745.6.camel@sipsolutions.net>
References: <20170203163607.3488037-1-arnd@arndb.de>
         <20170206.120318.1268240226202516488.davem@davemloft.net>
         <4910112.l20yySyWnA@wuerfel> (sfid-20170208_130733_449950_64BEF84C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: stable@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrey Ryabinin <a.ryabinin@samsung.com>,
        nikolay@cumulusnetworks.com, nicolas.dichtel@6wind.com,
        adobriyan@gmail.com,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4910112.l20yySyWnA@wuerfel> (sfid-20170208_130733_449950_64BEF84C)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-02-08 at 13:03 +0100, Arnd Bergmann wrote:
> 
> - Moving nla_put_{u8,u16,u32} out of line is probably uncontroversial
> and
>   it helps enough with br_netlink.c, but nl820211 is worse and needs
> some
>   additional fiddling.

Why would that not be sufficient by itself for nl80211?

Btw, what's causing this to start with? Can't the compiler reuse the
stack places?

johannes
