From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Mon, 06 Dec 2010 20:46:46 -0800 (PST)
Message-ID: <20101206.204646.59694635.davem@davemloft.net>
References: <20101207120039.6ea1491e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com,
	leitao@linux.vnet.ibm.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101207120039.6ea1491e.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 7 Dec 2010 12:00:39 +1100

> After merging the net tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> drivers/net/ehea/ehea_main.c: In function 'ehea_refill_rq1':
> drivers/net/ehea/ehea_main.c:405: error: implicit declaration of function 'ehea_info'
> drivers/net/ehea/ehea_main.c: In function 'ehea_init_fill_rq1':
> drivers/net/ehea/ehea_main.c:429: error: implicit declaration of function 'ehea_error'
> drivers/net/ehea/ehea_main.c: In function 'ehea_neq_tasklet':
> drivers/net/ehea/ehea_main.c:1306: warning: format '%lx' expects type 'long unsigned int', but argument 2 has type 'u64'
> 
> Caused by commit 539995d18649023199986424d140f1d620372ce5 ("ehea: Use the
> standard logging functions") interacting with commit
> 5c7e57f7cddb83d81d83fefa5822dfe80891130e ("ehea: Add some info messages
> and fix an issue") which went into Linus' tree before 2.6.37-rc4.
> 
> Presumably a merge of net-current into the net tree will need a fixup patch.
> 
> I have used the net tree from next-20101206 for today.

I'm reverting Joe's change from net-next-2.6 to handle this, Joe can
resubmit after I next do a net-2.6 --> net-next-2.6 merge
