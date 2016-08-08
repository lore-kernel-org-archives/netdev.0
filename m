From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH 0/3] net: Improve snmp6_fill_stats
Date: Mon,  8 Aug 2016 18:22:19 +0800
Message-ID: <1470651742-15195-1-git-send-email-hejianet@gmail.com>
Cc: linux-kernel@vger.kernel.org, Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the follow up work of commit a3a773726c9f ("net: Optimize 
snmp stat aggregation by walking all the percpu data at once") 

Jia He (3):
  net: Remove unnecessary memset in __snmp6_fill_stats64
  net: Replace for_each_possible_cpu with for_each_online_cpu
  net: Remove the useless parameter of __snmp6_fill_statsdev

 net/ipv6/addrconf.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

-- 
2.5.0
