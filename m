From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Mon, 4 Jul 2016 13:15:52 +1000
Message-ID: <20160704131552.22b44d58@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) produced this warning:

drivers/net/tun.c: In function 'tun_do_read.part.5':
/home/sfr/next/next/drivers/net/tun.c:1491:6: warning: 'err' may be used uninitialized in this function [-Wmaybe-uninitialized]
  int err;
      ^

Introduced by commit

  1576d9860599 ("tun: switch to use skb array for tx")

I can't easily see if this is a false positive.

-- 
Cheers,
Stephen Rothwell
