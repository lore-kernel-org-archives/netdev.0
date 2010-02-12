From: David Miller <davem@davemloft.net>
Subject: Re: bug and question in tcp stack
Date: Fri, 12 Feb 2010 15:39:07 -0800 (PST)
Message-ID: <20100212.153907.71316958.davem@davemloft.net>
References: <157135.69931.qm@web63405.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: caoco2002@yahoo.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <157135.69931.qm@web63405.mail.re1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Cao <caoco2002@yahoo.com>
Date: Fri, 12 Feb 2010 15:22:16 -0800 (PST)

> if (tcp_retransmit_skb(sk, tcp_write_queue_head(sk)) > 0) {
> 
> checks the return value as a positive number, which will never be true.

It can, recheck the code paths.

The upcall to send an SKB out through the packet schedular and onwards
to the actual device can return congestion notification values, which
are positive.
