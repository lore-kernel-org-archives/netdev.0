From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: tun: add tun_flags, owner, group attributes in sysfs
Date: Sat, 09 May 2009 23:27:53 +0100
Message-ID: <1241908073.24436.27.camel@macbook.infradead.org>
References: <1241433136.6126.70.camel@macbook.infradead.org>
	 <20090509.132733.213857911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59150 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753149AbZEIW14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 18:27:56 -0400
In-Reply-To: <20090509.132733.213857911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-05-09 at 13:27 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Mon, 04 May 2009 11:32:16 +0100
> 
> > I don't have to explicitly remove the files, do I? They go away
> > naturally when the device is unregistered?
> 
> I'm not so sure about this.  I can't see anything in the
> drivers/base/core.c code that automatically deletes anything
> other than device groups and attributes.

Hm, I really do think the attributes go away automatically when the
parent device does.

If not, gianfar_sysfs.c and niu.c want fixing too -- and we should
probably have a WARN_ON() in the sysfs code when it happens, if
possible.

I'll experiment (since I'm getting lost when I try to work it out by
inspection).

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

