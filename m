From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ATM-ENI: Use kmalloc_array() in eni_start()
Date: Fri, 09 Sep 2016 19:26:52 -0700 (PDT)
Message-ID: <20160909.192652.526503079536383297.davem@davemloft.net>
References: <d8468294-dff0-f34c-bf16-bb04435d465c@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
        3chas3@gmail.com, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr,
        pbonzini@redhat.com
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <d8468294-dff0-f34c-bf16-bb04435d465c@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 8 Sep 2016 14:40:06 +0200

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 8 Sep 2016 14:20:17 +0200
> 
> * A multiplication for the size determination of a memory allocation
>   indicated that an array data structure should be processed.
>   Thus use the corresponding function "kmalloc_array".
> 
>   This issue was detected by using the Coccinelle software.
> 
> * Replace the specification of a data structure by a pointer dereference
>   to make the corresponding size determination a bit safer according to
>   the Linux coding style convention.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied to net-next.
