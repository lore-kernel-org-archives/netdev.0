From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
Date: Tue, 15 Jul 2014 23:54:12 +0200
Message-ID: <20140715215412.GA19363@electric-eye.fr.zoreil.com>
References: <1405406500-1208-1-git-send-email-michel@daenzer.net>
 <0835B3720019904CB8F7AA43166CEEB25066DC@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michel =?utf-8?Q?D=C3=A4nzer?= <michel@daenzer.net>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB25066DC@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
>  Michel D?nzer [mailto:michel@daenzer.net] 
[...]
> > Without this, the ethernet port on my ASUS A88X Pro mainboard stops
> > working sometimes, with messages like these in dmesg:
> > 
> > AMD-Vi: Event logged [IO_PAGE_FAULT device=05:00.0 
> > domain=0x001e address=0x0000000000003000 flags=0x0050]
> 
> I search the information about your issue. It seems to be
> relative to the IOMMU. I don't sure if your patch is the root
> cause or a workaround.

Btw, a few extra identifiers in rtl_init_rxcfg may improve consistency:

           missing             |          included
-------------------------------+-------------------------------
RTL_GIGA_MAC_VER_36 (8168f)    | RTL_GIGA_MAC_VER_35 (8168f)
RTL_GIGA_MAC_VER_38 (RTL8411)  | RTL_GIGA_MAC_VER_44 (RTL8411)
RTL_GIGA_MAC_VER_39 (RTL8106e) | RTL_GIGA_MAC_VER_43 (RTL8106e)
RTL_GIGA_MAC_VER_37 (RTL8402)  |

-- 
Ueimor
