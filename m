From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM-iphase: Use kmalloc_array() in tx_init()
Date: Fri, 09 Sep 2016 21:01:17 -0700 (PDT)
Message-ID: <20160909.210117.1717988451564525754.davem@davemloft.net>
References: <87a58007-c560-eb8d-b268-5a25452a8daf@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        3chas3@gmail.com, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr,
        pbonzini@redhat.com
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87a58007-c560-eb8d-b268-5a25452a8daf@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 9 Sep 2016 20:42:16 +0200

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 9 Sep 2016 20:40:16 +0200
> 
> * Multiplications for the size determination of memory allocations
>   indicated that array data structures should be processed.
>   Thus use the corresponding function "kmalloc_array".
> 
>   This issue was detected by using the Coccinelle software.
> 
> * Replace the specification of data types by pointer dereferences
>   to make the corresponding size determination a bit safer according to
>   the Linux coding style convention.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
