From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 01:49:23 -0700 (PDT)
Message-ID: <20090421.014923.169153421.davem@davemloft.net>
References: <49ED6D2E.5060808@cn.fujitsu.com>
	<20090421081649.GA16782@ioremap.net>
	<49ED8700.3010603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, shemminger@vyatta.com, dada1@cosmosbay.com,
	paulus@samba.org, paulmck@linux.vnet.ibm.com, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: laijs@cn.fujitsu.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755886AbZDUIts@vger.kernel.org>
In-Reply-To: <49ED8700.3010603@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Tue, 21 Apr 2009 16:42:40 +0800

> softirq is always not nesting. Why we need recursive lock?

Netfilter itself, is nesting.

When using bridging netfilter, iptables can be entered twice
in the same call chain.
