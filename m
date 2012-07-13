From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: Add new network device function to allow
 for MMIO batching
Date: Fri, 13 Jul 2012 18:23:24 +0200
Message-ID: <1342196604.3265.8485.camel@edumazet-glaptop>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
	 <20120712002603.27846.23752.stgit@gitlad.jf.intel.com>
	 <1342077259.3265.8232.camel@edumazet-glaptop> <4FFEEF99.7030707@intel.com>
	 <1342165129.3265.8320.camel@edumazet-glaptop>
	 <20120713085007.596a2924@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, therbert@google.com,
	alexander.duyck@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63219 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756760Ab2GMQX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 12:23:29 -0400
Received: by bkwj10 with SMTP id j10so3318768bkw.19
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 09:23:28 -0700 (PDT)
In-Reply-To: <20120713085007.596a2924@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-13 at 08:50 -0700, Stephen Hemminger wrote:
> On Fri, 13 Jul 2012 09:38:49 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Frankly what percentage of linux powered machines act as high perf
> > routers ?
> 
> More than you think, every Linux machine acting as hypervisor (Xen and KVM)
> is also doing this.


High perf router meant : ability to route 10 Mpps, without help of TSO.

If an hypervisor is enable to use TSO, I expect very bad performances
anyway.
