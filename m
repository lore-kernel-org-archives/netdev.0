From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Thu, 08 Apr 2010 06:59:34 +0200
Message-ID: <1270702774.8141.49.camel@edumazet-laptop>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>
	 <alpine.DEB.2.00.1003250942080.2670@router.home>
	 <1269570902.9614.92.camel@alexs-hp.sh.intel.com>
	 <1270114166.2078.107.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004011050340.16531@router.home>
	 <1270195589.2078.116.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004050853300.23149@router.home>
	 <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>
	 <4BBA8DF9.8010409@kernel.org>
	 <1270542497.2078.123.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004061033330.18750@router.home>
	 <alpine.DEB.2.00.1004061552500.19151@router.home>
	 <1270591841.2091.170.camel@edumazet-laptop>
	 <1270607668.2078.259.camel@ymzhang.sh.intel.com>
	 <alpine.DEB.2.00.1004071130260.13261@router.home>
	 <4BBCB7B7.4040901@cs.helsinki.fi> <4BBCB868.2000705@cs.helsinki.fi>
	 <alpine.DEB.2.00.1004071319320.16159@router.home>
	 <1270665484.8141.47.camel@edumazet-laptop>
	 <1270688747.2078.383.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65464 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab0DHE7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:59:42 -0400
In-Reply-To: <1270688747.2078.383.camel@ymzhang.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 09:05 +0800, Zhang, Yanmin a =C3=A9crit :

> > Do we have a user program to check actual L1 cache size of a machin=
e ?
> If there is no, it's easy to write it as kernel exports the cache sta=
t by
> /sys/devices/system/cpu/cpuXXX/cache/indexXXX/

Yes, this is what advertizes my L1 cache having 64bytes lines, but I
would like to check that in practice, this is not 128bytes...

=2E/index0/type:Data
=2E/index0/level:1
=2E/index0/coherency_line_size:64
=2E/index0/physical_line_partition:1
=2E/index0/ways_of_associativity:8
=2E/index0/number_of_sets:64
=2E/index0/size:32K
=2E/index0/shared_cpu_map:00000101
=2E/index0/shared_cpu_list:0,8
=2E/index1/type:Instruction
=2E/index1/level:1
=2E/index1/coherency_line_size:64
=2E/index1/physical_line_partition:1
=2E/index1/ways_of_associativity:4
=2E/index1/number_of_sets:128
=2E/index1/size:32K
=2E/index1/shared_cpu_map:00000101
=2E/index1/shared_cpu_list:0,8


