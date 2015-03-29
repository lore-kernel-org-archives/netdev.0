From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 1/2] net: neighbour: Add mcast_resolicit to configure
 the number of multicast resolicitations in PROBE state.
Date: Mon, 30 Mar 2015 08:49:44 +0900
Message-ID: <55188F98.7020803@miraclelinux.com>
References: <20150319.224146.893461080038567220.yoshfuji@yoshifuji-H87MS01.miraclelinux.com> <551525F2.3040107@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hideaki.yoshifuji@miraclelinux.com,
	Yanjun.Zhu@windriver.com
To: Ulf Samuelsson <ulf.samuelsson@ericsson.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og109.obsmtp.com ([64.18.2.171]:58729 "HELO
	exprod7og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751282AbbC2Xtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 19:49:49 -0400
Received: by mail-pd0-f177.google.com with SMTP id ni2so157058039pdb.1
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 16:49:48 -0700 (PDT)
In-Reply-To: <551525F2.3040107@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ulf Samuelsson wrote:
> Should not this patch add modifications to "kernel/sysctl_binary.c" and
> "include/linux/sysctl.h" as well?

We do not add binary sysctls any more.


> mcast_probes and ucast_probes are initialized in arp.c and ndisc.c.
> Should we not initialize also mcast_reprobes, even if it is zero?

We could, but unneccessary.


> There are some statistics printout in net/core/neighbour.c.
> They handle mcast_solicit and ucast_solicit.
> 
> Are they unneccessary for mcast_resolicit?

Not neccessary.
Hint: What are those for?  Where/How do we increment those counters?

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
