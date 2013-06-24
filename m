From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] [NET]: Unmap fragment page once iterator is done
Date: Mon, 24 Jun 2013 14:35:19 +0400
Message-ID: <51C820E7.6040004@cogentembedded.com>
References: <1372055628-27044-1-git-send-email-wedsonaf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wedson Almeida Filho <wedsonaf@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372055628-27044-1-git-send-email-wedsonaf@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 24-06-2013 10:33, Wedson Almeida Filho wrote:

> Callers of skb_seq_read() are currently forced to call skb_abort_seq_read()
> even when consuming all the data because the last call to skb_seq_read (the
> one that returns 0 to indicate the end) fails to unmap the last fragment page.

> With this patch callers will be allowed to traverse the SKB data by calling
> skb_prepare_seq_read() once and repeatedly calling skb_seq_read() as originally
> intended (and documented in the original commit 677e90eda), that is, only call

    Please also specify the summary line of that commit.

> skb_abort_seq_read() if the sequential read is actually aborted.

> Signed-off-by: Wedson Almeida Filho <wedsonaf@gmail.com>

WBR, Sergei
