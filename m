From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/4] net_dma: revert 'copied_early'
Date: Mon, 13 Jan 2014 21:16:19 -0800 (PST)
Message-ID: <20140113.211619.613683326137425186.davem@davemloft.net>
References: <20140114004509.27138.50345.stgit@viggo.jf.intel.com>
	<20140114004637.27138.50365.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmaengine@vger.kernel.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, saidi@engin.umich.edu, jmorris@namei.org,
	edumazet@google.com, kuznet@ms2.inr.ac.ru, davej@redhat.com,
	ncardwell@google.com, kaber@trash.net, linux-kernel@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140114004637.27138.50365.stgit@viggo.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 Jan 2014 16:47:14 -0800

> Now that tcp_dma_try_early_copy() is gone nothing ever sets
> copied_early.
> 
> Also reverts "53240c208776 tcp: Fix possible double-ack w/ user dma"
> since it is no longer necessary.
> 
> Cc: Ali Saidi <saidi@engin.umich.edu>
> Cc: James Morris <jmorris@namei.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Neal Cardwell <ncardwell@google.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: David S. Miller <davem@davemloft.net>
