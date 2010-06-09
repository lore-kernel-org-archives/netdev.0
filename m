From: Miles Lane <miles.lane@gmail.com>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
	rcu_dereference_check() without protection!
Date: Wed, 9 Jun 2010 17:15:27 -0400
Message-ID: <AANLkTilG5bjN5QaOChmuVN6vT7kMK4eGaV-DvPynBn_t@mail.gmail.com>
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
	<1276106229.1745.65.camel@laptop>
	<1276107311.1745.66.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52307 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108Ab0FIVP3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 17:15:29 -0400
Received: by wyb40 with SMTP id 40so524894wyb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 14:15:28 -0700 (PDT)
In-Reply-To: <1276107311.1745.66.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 9, 2010 at 2:15 PM, Peter Zijlstra <peterz@infradead.org> w=
rote:
> On Wed, 2010-06-09 at 19:57 +0200, Peter Zijlstra wrote:
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* We're not in the pid-hash yet so no cgroup attach=
 races, and the
>> + =A0 =A0 =A0 =A0* cgroup is pinned by the parent running this.
>> + =A0 =A0 =A0 =A0*
>> + =A0 =A0 =A0 =A0* Silence PROVE_RCU.
>> + =A0 =A0 =A0 =A0*/
>
> Hum,.. not sure that's actually true though, the parent itself is sti=
ll
> susceptible to races afaict..

Do you want what you sent earlier tested, or should I wait for another =
patch?
