From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
 rcu_dereference_check() without protection!
Date: Wed, 09 Jun 2010 23:20:58 +0200
Message-ID: <1276118458.1745.144.camel@laptop>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	 <20100608001929.GF2387@linux.vnet.ibm.com>
	 <AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
	 <1275986441.5408.111.camel@twins>
	 <AANLkTimXVlgzHivCQberLdrFP8BH_nJzt8_ozUNHG_aI@mail.gmail.com>
	 <1276004075.2987.208.camel@twins>
	 <AANLkTil6ucLZ0A6tWx-OQt_2EeKnx8nSx6rIg2t1L2t5@mail.gmail.com>
	 <1276097068.1745.13.camel@laptop>
	 <AANLkTinl2JKUX6859Ioa1y0DqHWXH5TrkissQ8BAF4cP@mail.gmail.com>
	 <AANLkTilpM9O373rA0cw_wTYVfTiDPbjaKHScAGlt7IAr@mail.gmail.com>
	 <1276106229.1745.65.camel@laptop> <1276107311.1745.66.camel@laptop>
	 <AANLkTilG5bjN5QaOChmuVN6vT7kMK4eGaV-DvPynBn_t@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: paulmck@linux.vnet.ibm.com, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43082 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125Ab0FIVVZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 17:21:25 -0400
In-Reply-To: <AANLkTilG5bjN5QaOChmuVN6vT7kMK4eGaV-DvPynBn_t@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-09 at 17:15 -0400, Miles Lane wrote:
> On Wed, Jun 9, 2010 at 2:15 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Wed, 2010-06-09 at 19:57 +0200, Peter Zijlstra wrote:
> >> +       /*
> >> +        * We're not in the pid-hash yet so no cgroup attach races, and the
> >> +        * cgroup is pinned by the parent running this.
> >> +        *
> >> +        * Silence PROVE_RCU.
> >> +        */
> >
> > Hum,.. not sure that's actually true though, the parent itself is still
> > susceptible to races afaict..
> 
> Do you want what you sent earlier tested, or should I wait for another patch?

please wait, I need to sit down and sort out that code.
