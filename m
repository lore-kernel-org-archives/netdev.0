From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 57/68] DockBook: include/net/sock.h:442: warning:
 No description found for parameter 'sk_rcu'
Date: Tue, 5 Apr 2016 12:29:25 +0800
Message-ID: <201604051212.ZRyaOxrm%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="OXfL5xGRrasGEqWY"
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:11075 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbcDEEan (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 00:30:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   15f41e2ba13a6726632e44b1180e805a61e470ad
commit: a4298e4522d687a79af8f8fbb7eca68399ab2d81 [57/68] net: add SOCK_RCU_FREE socket flag
reproduce: make htmldocs

All warnings (new ones prefixed by >>):

   include/linux/skbuff.h:923: warning: No description found for parameter 'sk'
>> include/net/sock.h:442: warning: No description found for parameter 'sk_rcu'
   net/core/filter.c:1251: warning: No description found for parameter 'locked'

vim +/sk_rcu +442 include/net/sock.h

ef64a54f6 Pavel Emelyanov 2012-02-21  426  	__s32			sk_peek_off;
^1da177e4 Linus Torvalds  2005-04-16  427  	int			sk_write_pending;
d5f642384 Alexey Dobriyan 2008-11-04  428  #ifdef CONFIG_SECURITY
^1da177e4 Linus Torvalds  2005-04-16  429  	void			*sk_security;
d5f642384 Alexey Dobriyan 2008-11-04  430  #endif
2a56a1fec Tejun Heo       2015-12-07  431  	struct sock_cgroup_data	sk_cgrp_data;
baac50bbc Johannes Weiner 2016-01-14  432  	struct mem_cgroup	*sk_memcg;
^1da177e4 Linus Torvalds  2005-04-16  433  	void			(*sk_state_change)(struct sock *sk);
676d23690 David S. Miller 2014-04-11  434  	void			(*sk_data_ready)(struct sock *sk);
^1da177e4 Linus Torvalds  2005-04-16  435  	void			(*sk_write_space)(struct sock *sk);
^1da177e4 Linus Torvalds  2005-04-16  436  	void			(*sk_error_report)(struct sock *sk);
^1da177e4 Linus Torvalds  2005-04-16  437  	int			(*sk_backlog_rcv)(struct sock *sk,
^1da177e4 Linus Torvalds  2005-04-16  438  						  struct sk_buff *skb);
^1da177e4 Linus Torvalds  2005-04-16  439  	void                    (*sk_destruct)(struct sock *sk);
ef456144d Craig Gallek    2016-01-04  440  	struct sock_reuseport __rcu	*sk_reuseport_cb;
a4298e452 Eric Dumazet    2016-04-01  441  	struct rcu_head		sk_rcu;
^1da177e4 Linus Torvalds  2005-04-16 @442  };
^1da177e4 Linus Torvalds  2005-04-16  443  
559835ea7 Pravin B Shelar 2013-09-24  444  #define __sk_user_data(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
559835ea7 Pravin B Shelar 2013-09-24  445  
559835ea7 Pravin B Shelar 2013-09-24  446  #define rcu_dereference_sk_user_data(sk)	rcu_dereference(__sk_user_data((sk)))
559835ea7 Pravin B Shelar 2013-09-24  447  #define rcu_assign_sk_user_data(sk, ptr)	rcu_assign_pointer(__sk_user_data((sk)), ptr)
559835ea7 Pravin B Shelar 2013-09-24  448  
4a17fd522 Pavel Emelyanov 2012-04-19  449  /*
4a17fd522 Pavel Emelyanov 2012-04-19  450   * SK_CAN_REUSE and SK_NO_REUSE on a socket mean that the socket is OK

:::::: The code at line 442 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--OXfL5xGRrasGEqWY
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--OXfL5xGRrasGEqWY--
