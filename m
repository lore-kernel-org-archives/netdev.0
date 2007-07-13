From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH v2 -mm 5/9] netconsole: Introduce netconsole_target
Date: Fri, 13 Jul 2007 22:46:19 +0900
Message-ID: <4697822B.4050407@bx.jp.nec.com>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in> <20070710091946.23907.96503.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:56263 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932440AbXGMNqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 09:46:18 -0400
In-Reply-To: <20070710091946.23907.96503.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [5/9] netconsole: Introduce netconsole_target
> 
> Introduce a wrapper structure over netpoll to represent logging targets
> configured in netconsole. This will get extended with other members in
> further patches.
> 
> The original patchset did this along with (and inside the #ifdef) of
> CONFIG_NETCONSOLE_DYNAMIC itself. I decided otherwise, and was able to
> drastically cut down on the #ifdef-complexity of final netconsole.c.
> Also, struct netconsole_target would be required for multiple targets
> support also, and not just dynamic reconfigurability. Previously these
> two things were coupled, but I want to de-link that (more on this later).
> 
> Note that this patch in itself looks quite redundant / stupid, but it is
> purposefully made this way, so further patches are more readable.
> 
> Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> 
Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>

Thanks
--
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com
