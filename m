From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH -mm 9/9] netconsole: Support dynamic reconfiguration using
 configfs
Date: Sun, 08 Jul 2007 03:33:59 +0900
Message-ID: <468FDC97.3050409@bx.jp.nec.com>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:40282 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752998AbXGGSg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 14:36:56 -0400
In-Reply-To: <20070704110824.28520.11661.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> After more discussion, Joel suggested the idea to separately manage the
> lifetimes of the two kinds of netconsole_target objects, those created while
> parsing boot/module options and those created via configfs mkdir(2) from
> userspace, in my driver itself. That adds a little bit of complexity and
> redundancy (multiple item creation and destruction points) in this driver.
> Note that the latter type (configfs-created netconsole_targets) can be
> modified / updated / destroyed at runtime from userspace but the former
> (param string created) cannot, as they are not exposed through our configfs
> namespace. However, this is not really a problem and is similar to current
> behaviour in any case.

Maybe you should add the above description into 
Documentation/networking/netconsole.txt.
The users of netconsole applied these patches may think that they can change 
parameters of netconsole_target(param string created at the time of parsing 
boot/options).

And I'm going to search the another solution of this problem and read the 
code of configfs.

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com


