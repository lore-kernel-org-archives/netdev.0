From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net-next tree
Date: Mon, 15 Feb 2016 13:09:41 +1100
Message-ID: <20160215130941.4ce2ae28@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nikolay Borisov <n.borisov@siteground.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net-next tree, today's linux-next build (arm
multi_v7_defconfig) produced this warning:

net/ipv4/igmp.c: In function 'igmp_group_added':
net/ipv4/igmp.c:1227:14: warning: unused variable 'net' [-Wunused-variable]
  struct net *net = dev_net(in_dev->dev);
              ^
net/ipv4/igmp.c: In function 'ip_mc_inc_group':
net/ipv4/igmp.c:1319:14: warning: unused variable 'net' [-Wunused-variable]
  struct net *net = dev_net(in_dev->dev);
              ^
net/ipv4/igmp.c: In function 'ip_mc_init_dev':
net/ipv4/igmp.c:1646:14: warning: unused variable 'net' [-Wunused-variable]
  struct net *net = dev_net(in_dev->dev);
              ^
net/ipv4/igmp.c: In function 'ip_mc_up':
net/ipv4/igmp.c:1665:14: warning: unused variable 'net' [-Wunused-variable]
  struct net *net = dev_net(in_dev->dev);
              ^

Introduced by commits

  87a8a2ae65b7 ("igmp: Namespaceify igmp_llm_reports sysctl knob")
  165094afcee7 ("igmp: Namespacify igmp_qrv sysctl knob")

CONFIG_IP_MULTICAST is not set for this build.

-- 
Cheers,
Stephen Rothwell
