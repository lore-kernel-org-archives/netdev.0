From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next:master 33/33] net/sched/sch_dsmark.c:316:1: error:
 unrecognizable insn:
Date: Fri, 18 Sep 2015 21:18:59 +0800
Message-ID: <20150918131859.GA16463@wfg-t540p.sh.intel.com>
References: <201509181536.Z7Byr84l%fengguang.wu@intel.com>
 <1442577669.7946.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56838 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbbIRNS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Sep 2015 09:18:59 -0400
Content-Disposition: inline
In-Reply-To: <1442577669.7946.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > All error/warnings (new ones prefixed by >>):
> > 
> >    net/sched/sch_dsmark.c: In function 'dsmark_dequeue':
> > >> net/sched/sch_dsmark.c:316:1: error: unrecognizable insn:
> >    (insn 245 244 119 15 (set (reg:QI 11 r11 [179])
> >            (and:QI (mem/s/j:QI (reg/f:SI 2 r2 [orig:48 D.44551 ] [48]) [0 D.44551_34->mask+0 S1 A8])
> >                (reg:QI 11 r11 [179]))) include/net/dsfield.h:33 -1
> >         (nil))
> > >> net/sched/sch_dsmark.c:316:1: internal compiler error: in extract_insn, at recog.c:2109
> >    Please submit a full bug report,
> >    with preprocessed source if appropriate.
> >    See <http://gcc.gnu.org/bugs.html> for instructions.

> I assume this is an informational message, and that you'll submit a gcc
> bug report ?

I'm not sure if gcc people would be interested because that's a pretty
old cross compiler for ARCH=cris.

Someday 0day will be able to track regressions in gcc, which may be
useful for them. :)

Thanks,
Fengguang
