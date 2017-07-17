From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/11] net: ec_bhf: constify pci_device_id.
Date: Mon, 17 Jul 2017 13:38:16 -0700 (PDT)
Message-ID: <20170717.133816.1738351399213402373.davem@davemloft.net>
References: <1500315154-3304-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: reksio@newterm.pl, kvalo@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500315154-3304-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Mon, 17 Jul 2017 23:42:34 +0530

> pci_device_id are not supposed to change at runtime. All functions
> working with pci_device_id provided by <linux/pci.h> work with
> const pci_device_id. So mark the non-const structs as const.
> 
> File size before:
>    text	   data	    bss	    dec	    hex	filename
>    5113	    384	      0	   5497	   1579	drivers/net/ethernet/ec_bhf.o
> 
> File size After adding 'const':
>    text	   data	    bss	    dec	    hex	filename
>    5177	    320	      0	   5497	   1579	drivers/net/ethernet/ec_bhf.o
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Applied.
