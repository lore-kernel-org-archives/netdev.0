From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: broadcom: bnx2x: make a couple of const arrays
 static
Date: Thu, 13 Jul 2017 09:24:32 -0700 (PDT)
Message-ID: <20170713.092432.1028640160021503815.davem@davemloft.net>
References: <20170711105223.14024-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, ariel.elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170711105223.14024-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 11 Jul 2017 11:52:23 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate various tables on the stack but make them static const.
> Makes the object code smaller by nearly 200 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>  113468	  11200	      0	 124668	  1e6fc	bnx2x_ethtool.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>  113129	  11344	      0	 124473	  1e639	bnx2x_ethtool.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
