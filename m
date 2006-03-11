From: Adrian Bunk <bunk@stusta.de>
Subject: drivers/net/chelsio/sge.c: two array overflows
Date: Sat, 11 Mar 2006 02:37:20 +0100
Message-ID: <20060311013720.GG21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932366AbWCKBhX@vger.kernel.org>
To: maintainers@chelsio.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker spotted the following two array overflows in 
drivers/net/chelsio/sge.c (in both cases, the arrays contain 3 elements):

<--  snip  -->

...
static void restart_tx_queues(struct sge *sge)
{
...
                                sge->stats.cmdQ_restarted[3]++;
...
static int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
                     unsigned int qid, struct net_device *dev)
{
...
                        sge->stats.cmdQ_full[3]++;
...

<--  snip  -->


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
