From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM-ForeRunnerHE: Use kmalloc_array() in
 he_init_group()
Date: Fri, 09 Sep 2016 19:27:50 -0700 (PDT)
Message-ID: <20160909.192750.65059727736015475.davem@davemloft.net>
References: <edd03d91-0aff-73ed-cb04-c5851ac90dca@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        3chas3@gmail.com, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr,
        pbonzini@redhat.com
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <edd03d91-0aff-73ed-cb04-c5851ac90dca@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 8 Sep 2016 15:50:05 +0200

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 8 Sep 2016 15:43:37 +0200
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
