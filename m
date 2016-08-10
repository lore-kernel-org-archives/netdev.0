From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH 0/2] Convert qdisc linked list into a hashtable
Date: Wed, 10 Aug 2016 11:00:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a respin of the v6 of the original patch [1], split into two-patch 
series as requested by davem; first patch fixes all symbol conflicts 
that'd happen once netdevice.h starts to include hashtable.h, the second 
one performs the actual switch to hashtable.

I've preserved Cong's Reviewed-by:, as code-wise this series is identical 
to the original v6 of the patch.

[1] lkml.kernel.org/r/alpine.LNX.2.00.1608011220580.22028@cbobk.fhfr.pm

-- 
Jiri Kosina
SUSE Labs
