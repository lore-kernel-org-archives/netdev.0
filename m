From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Tue, 6 Oct 2015 16:34:39 +1100
Message-ID: <20151006163439.039784a0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (i386 defconfig)
failed like this:

net/built-in.o: In function `fib_rebalance':
fib_semantics.c:(.text+0x9d6d4): undefined reference to `__divdi3'

Caused by commit

  0e884c78ee19 ("ipv4: L3 hash-based multipath")

I have reverted that commit (and the following commit since it may depend
on the former) for today.

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
