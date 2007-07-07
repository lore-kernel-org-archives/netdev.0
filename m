From: KII Keiichi <k-keiichi@bx.jp.nec.com>
Subject: Re: [PATCH -mm 8/9] netconsole: Update documentation for dynamic
 reconfigurability
Date: Sun, 08 Jul 2007 03:33:53 +0900
Message-ID: <468FDC91.2080300@bx.jp.nec.com>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in> <468CEAEC.7040102@bx.jp.nec.com> <Pine.LNX.4.64.0707051913001.19842@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:37546 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbXGGSgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2007 14:36:51 -0400
In-Reply-To: <Pine.LNX.4.64.0707051913001.19842@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Satyam,

> BTW I did some testing myself, and have found another *embarrassing* bug:
> if netconsole is loaded _without_ specifying any "netconsole=" parameter,
> module is still kept loaded, but on unloading configfs_unregister_...()
> obviously panics! :-) This should've been found by me earlier, just that
> I never tested without specifying the parameter to modprobe :-(

I tested your patches on the x86 architecture and report the results.
It is no problem except for the above problem.
I think that it is useful to use configfs(especially, mkdir and rmdir 
because of adding/removing netconsole_target).

I am going to test the your next iteration patches on x86 and IA64 
architecutures. 

Thanks
-- 
Keiichi KII
NEC Corporation OSS Platform Development Division
E-mail: k-keiichi@bx.jp.nec.com




