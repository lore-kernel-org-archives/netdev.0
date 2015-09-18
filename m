From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next:master 33/33] net/sched/sch_dsmark.c:316:1: error:
 unrecognizable insn:
Date: Fri, 18 Sep 2015 05:01:09 -0700
Message-ID: <1442577669.7946.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201509181536.Z7Byr84l%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, kbuild-all@01.org,
	netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35903 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbbIRMBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 08:01:13 -0400
Received: by padhk3 with SMTP id hk3so49776990pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 05:01:12 -0700 (PDT)
In-Reply-To: <201509181536.Z7Byr84l%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-18 at 15:12 +0800, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   47bbbb30b4331ec58a74a66a044341f0114b02b3
> commit: 47bbbb30b4331ec58a74a66a044341f0114b02b3 [33/33] sch_dsmark: improve memory locality
> config: cris-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 47bbbb30b4331ec58a74a66a044341f0114b02b3
>   # save the attached .config to linux build tree
>   make.cross ARCH=cris 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    net/sched/sch_dsmark.c: In function 'dsmark_dequeue':
> >> net/sched/sch_dsmark.c:316:1: error: unrecognizable insn:
>    (insn 245 244 119 15 (set (reg:QI 11 r11 [179])
>            (and:QI (mem/s/j:QI (reg/f:SI 2 r2 [orig:48 D.44551 ] [48]) [0 D.44551_34->mask+0 S1 A8])
>                (reg:QI 11 r11 [179]))) include/net/dsfield.h:33 -1
>         (nil))
> >> net/sched/sch_dsmark.c:316:1: internal compiler error: in extract_insn, at recog.c:2109
>    Please submit a full bug report,
>    with preprocessed source if appropriate.
>    See <http://gcc.gnu.org/bugs.html> for instructions.
> 
> vim +316 net/sched/sch_dsmark.c
> 
> c76f2a2c4 Yang Yingliang    2013-12-23  310  			pr_warn("%s: unsupported protocol %d\n",
> d8b9605d2 Jiri Pirko        2015-01-13  311  				__func__, ntohs(tc_skb_protocol(skb)));
> ^1da177e4 Linus Torvalds    2005-04-16  312  		break;
> 3ff50b799 Stephen Hemminger 2007-04-20  313  	}
> af0d11417 Thomas Graf       2005-06-18  314  
> ^1da177e4 Linus Torvalds    2005-04-16  315  	return skb;
> ^1da177e4 Linus Torvalds    2005-04-16 @316  }
> ^1da177e4 Linus Torvalds    2005-04-16  317  
> 8e3af9789 Jarek Poplawski   2008-10-31  318  static struct sk_buff *dsmark_peek(struct Qdisc *sch)
> 8e3af9789 Jarek Poplawski   2008-10-31  319  {
> 
> :::::: The code at line 316 was first introduced by commit
> :::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2
> 
> :::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
> :::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

I assume this is an informational message, and that you'll submit a gcc
bug report ?

Thanks !
