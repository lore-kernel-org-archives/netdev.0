From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: make const array route_possibilities
 static
Date: Thu, 13 Jul 2017 09:24:38 -0700 (PDT)
Message-ID: <20170713.092438.1772000521677037512.davem@davemloft.net>
References: <20170711111848.14469-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170711111848.14469-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 11 Jul 2017 12:18:48 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't populate array route_possibilities on the stack but make it
> static const.  Makes the object code a little smaller by 85 bytes:
> 
> Before:
>    text	   data	    bss	    dec	    hex	filename
>    9901	   2448	      0	  12349	   303d	dwmac4_core.o
> 
> After:
>    text	   data	    bss	    dec	    hex	filename
>    9760	   2504	      0	  12264	   2fe8	dwmac4_core.o
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
