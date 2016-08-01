From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH v4] net: sched: convert qdisc linked list to hashtable
Date: Mon, 1 Aug 2016 12:12:42 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608011212080.22028@cbobk.fhfr.pm>
References: <201607281957.yJSK4rUm%fengguang.wu@intel.com> <alpine.LNX.2.00.1607281317350.24757@cbobk.fhfr.pm> <20160728125312.GB25433@wfg-t540p.sh.intel.com> <20160731112127.GA9518@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kbuild-all@01.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>
To: Fengguang Wu <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160731112127.GA9518@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 31 Jul 2016, Fengguang Wu wrote:

> Jiri, I just double checked and find no similar errors related to
> qdisc_list_add(). The parent commit 95556a8838 ("dccp: avoid deadlock
> in dccp_v4_ctl_send_reset") builds fine without error.

You are right, I realized my mistake afterwards. This is fixed in v5 of 
the patch.

Thanks,

-- 
Jiri Kosina
SUSE Labs
