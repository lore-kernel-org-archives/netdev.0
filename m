From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 8/9] netconsole: Update documentation for dynamic
 reconfigurability
Date: Thu, 5 Jul 2007 19:33:51 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707051929050.20044@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110819.28520.50445.sendpatchset@cselinux1.cse.iitk.ac.in>
 <468CEAEC.7040102@bx.jp.nec.com> <Pine.LNX.4.64.0707051913001.19842@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Keiichi KII <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:40604 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756609AbXGENmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 09:42:19 -0400
In-Reply-To: <Pine.LNX.4.64.0707051913001.19842@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Jul 2007, Satyam Sharma wrote:
> [...]
> BTW I did some testing myself, and have found another *embarrassing* bug:
> if netconsole is loaded _without_ specifying any "netconsole=" parameter,
> module is still kept loaded, but on unloading configfs_unregister_...()
> obviously panics! :-) This should've been found by me earlier, just that
> I never tested without specifying the parameter to modprobe :-(

Basically that check upfront in init_netconsole() checking if the boot/
module param was provided now becomes unnecessary -- with dynamic
reconfigurability, a user might plausibly want to load netconsole without
specifying any params, but add targets later ...

Satyam
