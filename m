From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/11] net: cadence: macb: constify pci_device_id.
Date: Mon, 17 Jul 2017 13:38:09 -0700 (PDT)
Message-ID: <20170717.133809.1388368429079194648.davem@davemloft.net>
References: <1500315112-3249-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@microchip.com, kvalo@codeaurora.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500315112-3249-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Mon, 17 Jul 2017 23:41:52 +0530

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>     791	    336	      0	   1127	    467	net/ethernet/cadence/macb_pci.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>     855	    272	      0	   1127	    467	net/ethernet/cadence/macb_pci.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
