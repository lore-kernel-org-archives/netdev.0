From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
Date: Tue, 09 Feb 2016 20:38:19 +0100
Message-ID: <4072312.pCFuaqSbhC@wuerfel>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com> <063D6719AE5E284EB5DD2968C1650D6D1CCDC216@AcuExch.aculab.com> <3E54258959B69E4282D79E01AB1F32B704D12E49@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Laight <David.Laight@aculab.com>,
	"Strashko, Grygorii" <grygorii.strashko@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"Cooper Jr., Franklin" <fcooper@ti.com>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: "Karicheri, Muralidharan" <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3E54258959B69E4282D79E01AB1F32B704D12E49@DFLE11.ent.ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 February 2016 16:55:42 Karicheri, Muralidharan wrote:
> 
> The descriptors are usable by different drivers, one driver may use it as 
> buf ptr/ len, other for something else. So they should remain as generic
> and it is up to individual drivers to use it in whatever way it requires.
> My suggestion is to rename pad field in struct knav_dma_desc to sw_data
> to avoid confusion. i.e 
> 
> +       __le32  pad[4];
> 
> to 
> 
> +       __le32  sw_data[4];
> 

If the hardware doesn't access them, they can probably just be u32
and not do any byte swapping.

	Arnd
