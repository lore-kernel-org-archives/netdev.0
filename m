From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Unmap fragment page once iterator is done
Date: Tue, 25 Jun 2013 16:20:54 -0700 (PDT)
Message-ID: <20130625.162054.890870423042371628.davem@davemloft.net>
References: <1372123520-18287-1-git-send-email-wedsonaf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wedsonaf@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372123520-18287-1-git-send-email-wedsonaf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wedson Almeida Filho <wedsonaf@gmail.com>
Date: Mon, 24 Jun 2013 18:25:20 -0700

> Callers of skb_seq_read() are currently forced to call skb_abort_seq_read()
> even when consuming all the data because the last call to skb_seq_read (the
> one that returns 0 to indicate the end) fails to unmap the last fragment page.
> 
> With this patch callers will be allowed to traverse the SKB data by calling
> skb_prepare_seq_read() once and repeatedly calling skb_seq_read() as originally
> intended (and documented in the original commit 677e90eda - "[NET]: Zerocopy
> sequential reading of skb data"), that is, only call skb_abort_seq_read() if
> the sequential read is actually aborted.
> 
> Signed-off-by: Wedson Almeida Filho <wedsonaf@gmail.com>

This patch doesn't even come close to applying to the net-next tree,
please respin this patch properly and resubmit.

Thanks.
