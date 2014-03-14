From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Fri, 14 Mar 2014 06:46:38 -0700
Message-ID: <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170546.3011.82918.stgit@nitbit.x32>
	 <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53208E3F.5090401@gmail.com>
	 <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313202245.GK21124@linux.vnet.ibm.com>
	 <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313211509.GP21124@linux.vnet.ibm.com> <53229704.1040808@gmail.com>
	 <20140314132834.GS21124@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:54918 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114AbaCNNqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 09:46:38 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so2603440pbb.8
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 06:46:37 -0700 (PDT)
In-Reply-To: <20140314132834.GS21124@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-14 at 06:28 -0700, Paul E. McKenney wrote:

> Now I just need to figure out why it -causes- a BUILD_BUG_ON for the
> cris and m68k architectures in Fengguang Wu's testing...

Right, they don't necessarily align pointers ;)

alignof(void *) ?
