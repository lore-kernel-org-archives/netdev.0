From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 15 Jun 2007 06:49:35 -0400
Message-ID: <1181904575.4102.31.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:61351 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbXFOKtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 06:49:39 -0400
Received: by py-out-1112.google.com with SMTP id a29so1488842pyi
        for <netdev@vger.kernel.org>; Fri, 15 Jun 2007 03:49:38 -0700 (PDT)
In-Reply-To: <1181870826.4092.29.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Yi,

On Fri, 2007-15-06 at 09:27 +0800, Zhu Yi wrote:

> 1. driver becomes complicated (as it is too elaborate in the queue
> wakeup strategies design)

I am not sure i see the complexity in the wireless driver's wakeup
strategy. I just gave some suggestions to use management frames - they
dont have to be literally that way.

> 2. duplicated code among drivers (otherwise you put all the queue
> management logics in a new layer?)

There will be some shared code on drivers of same media on the
netif_stop/wake strategy perhaps, but not related to queue management. 

> 3. it's not 100% accurate. there has to be some overhead, more or less
> depends on the queue wakeup strategy the driver selected.

Why is it not accurate for wireless? I can see the corner case Patrick
mentioned in wired ethernet but then wired ethernet doesnt have other
events such as management frames (actually DCE does) to help. 

cheers,
jamal

