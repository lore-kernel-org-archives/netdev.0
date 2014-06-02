From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V6 2/2] net/mlx4_en: Use affinity hint
Date: Sun, 01 Jun 2014 22:13:12 -0700
Message-ID: <1401685992.3645.173.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401029247-15196-3-git-send-email-amirv@mellanox.com>
	 <1401682610.3645.166.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1401683831.3645.169.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140601.215650.2131746246978305213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, ogerlitz@mellanox.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, yuvala@mellanox.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140601.215650.2131746246978305213.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-06-01 at 21:56 -0700, David Miller wrote:

> Indeed you have to provide a dummy version for a non-SMP build etc.
> 
> I'm reverting.
> 

Hi David. I think your revert took one wrong commit.


# git show ee39facbf82e73e468c504d2b40e83e2d223c28c | diffstat -p1 -w70
 drivers/net/ethernet/micrel/ks8851.c |   50 ++++++++++---------
 include/linux/cpumask.h              |    2 
 lib/cpumask.c                        |   64 -------------------------
 3 files changed, 28 insertions(+), 88 deletions(-)
