From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib_trie: only calc for the un-first node
Date: Thu, 10 Oct 2013 00:17:22 -0400 (EDT)
Message-ID: <20131010.001722.880038875298978753.davem@davemloft.net>
References: <1381203411-12047-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381203411-12047-1-git-send-email-baker.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: baker.kernel@gmail.com
Date: Tue,  8 Oct 2013 11:36:51 +0800

> From: "baker.zhang" <baker.kernel@gmail.com>
> 
> This is a enhancement.
> 
> for the first node in fib_trie, newpos is 0, bit is 1.
> Only for the leaf or node with unmatched key need calc pos.
> 
> Signed-off-by: baker.zhang <baker.kernel@gmail.com>

The compiler is probably doing this transformation all by itself,
but applied anyways, thanks.
