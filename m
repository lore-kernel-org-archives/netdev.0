From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] [NET]: Unmap fragment page once iterator is done
Date: Mon, 24 Jun 2013 01:47:26 -0700 (PDT)
Message-ID: <20130624.014726.95868240491156656.davem@davemloft.net>
References: <1372055628-27044-1-git-send-email-wedsonaf@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wedsonaf@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372055628-27044-1-git-send-email-wedsonaf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wedson Almeida Filho <wedsonaf@gmail.com>
Date: Sun, 23 Jun 2013 23:33:48 -0700

> Callers of skb_seq_read() are currently forced to call skb_abort_seq_read()
> even when consuming all the data because the last call to skb_seq_read (the
> one that returns 0 to indicate the end) fails to unmap the last fragment page.
> 
> With this patch callers will be allowed to traverse the SKB data by calling
> skb_prepare_seq_read() once and repeatedly calling skb_seq_read() as originally
> intended (and documented in the original commit 677e90eda), that is, only call
> skb_abort_seq_read() if the sequential read is actually aborted.
> 
> Signed-off-by: Wedson Almeida Filho <wedsonaf@gmail.com>

Applied.

Please format your subject lines as:

[PATCH vx] net: xxxx

Because anything inside of "[]" are deleted by the automated patch
processing tools, and we now use lowercase for the subsystem
prefixes.

Thanks.
