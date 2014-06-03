From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: filter: fix possible memory leak in
 __sk_prepare_filter()
Date: Mon, 02 Jun 2014 17:50:09 -0700 (PDT)
Message-ID: <20140602.175009.223327851419748409.davem@davemloft.net>
References: <1401601045-7829-1-git-send-email-chianglungyu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chianglungyu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401601045-7829-1-git-send-email-chianglungyu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Leon Yu <chianglungyu@gmail.com>
Date: Sun,  1 Jun 2014 05:37:25 +0000

> __sk_prepare_filter() was reworked in commit bd4cf0ed3 (net: filter:
> rework/optimize internal BPF interpreter's instruction set) so that it should
> have uncharged memory once things went wrong. However that work isn't complete.
> Error is handled only in __sk_migrate_filter() while memory can still leak in
> the error path right after sk_chk_filter().
> 
> Signed-off-by: Leon Yu <chianglungyu@gmail.com>

Applied, thanks.
