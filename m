From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 04/10] sysctl: Fix neighbour table sysctls.
Date: Fri, 10 Aug 2007 11:22:33 +0900 (JST)
Message-ID: <20070810.112233.90409216.yoshfuji@linux-ipv6.org>
References: <m18x8k9ppv.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pj89pmt.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, adobriyan@sw.ru, netdev@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54254 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbXHJCVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 22:21:31 -0400
In-Reply-To: <m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <m1zm108axi.fsf_-_@ebiederm.dsl.xmission.com> (at Thu, 09 Aug 2007 18:56:09 -0600), ebiederm@xmission.com (Eric W. Biederman) says:

> 
> - In ipv6 ndisc_ifinfo_syctl_change so it doesn't depend on binary
>   sysctl names for a function that works with proc.
:

Well, retrans_time_ms and base_reachable_time_ms supercedes
retrans_time and base_reachable_time, we've warned for long
time for its deprecation.  So, maybe, it is time to remove
the old interfaces (retrans_time and base_reachable_time)
and simplify ndisc_ifinfo_syctl_change().

--yoshfuji
