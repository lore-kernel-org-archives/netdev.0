From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2] qed: Remove OOM messages
Date: Tue, 06 Sep 2016 13:54:42 -0700 (PDT)
Message-ID: <20160906.135442.1020937848957246873.davem@davemloft.net>
References: <c79eb789a95464ba5dc06229d905ca1ae00a66c8.1473024037.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
        everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c79eb789a95464ba5dc06229d905ca1ae00a66c8.1473024037.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun,  4 Sep 2016 14:24:03 -0700

> These messages are unnecessary as OOM allocation failures already do
> a dump_stack() giving more or less the same information.
> 
> $ size drivers/net/ethernet/qlogic/qed/built-in.o* (defconfig x86-64)
>    text	   data	    bss	    dec	    hex	filename
>  127817	  27969	  32800	 188586	  2e0aa	drivers/net/ethernet/qlogic/qed/built-in.o.new
>  132474	  27969	  32800	 193243	  2f2db	drivers/net/ethernet/qlogic/qed/built-in.o.old
> 
> Miscellanea:
> 
> o Change allocs to the generally preferred forms where possible.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
