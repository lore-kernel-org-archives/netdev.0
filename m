From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 7 Mar 2008 10:48:43 +0000
Message-ID: <20080307104843.GC4203@ff.dom.local>
References: <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local> <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local> <20080306233151.M43262@visp.net.lb> <20080307093150.GA4203@ff.dom.local> <20080307101504.M78767@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:3277 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396AbYCGKrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 05:47:25 -0500
Received: by ug-out-1314.google.com with SMTP id z38so4286918ugc.16
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2008 02:47:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080307101504.M78767@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 12:19:03PM +0200, Denys Fedoryshchenko wrote:
> Ok, i will proceed and will try all required options after few hours (need to 
> go another city, work).
> I will try to set max as possible debug options.

Max could be too much, but e.g. this is sometimes helpful too:
CONFIG_DEBUG_LIST is not set

BTW, you didn't write yet if with min/no debugging, no 4KSTACKS and
lockdep off there is any change in these lockups?

And no need to hurry...

> On bug_feb.txt it is triggering ONLY lockdep warning, but full network lockup 
> occur very rarely. But even it happens with me 2 times, i am not sure it is 
> same problem. Let's stick maybe to this one (lockdep warning) which is easy 
> to reproduce.
> I will open also bugzilla report.

Send Re: here with a bugzilla number.

> 
> Regarding testing with compiled in modules, i did
> CONFIG_IFB=y 
> CONFIG_DUMMY=y
> CONFIG_BONDING=y
> CONFIG_MACVLAN=y 
> CONFIG_EQUALIZER=y
> CONFIG_TUN=y
> 
> It is still triggering lockdep.
> Here is full dmesg:
> http://www.nuclearcat.com/files/dmesg_1234.txt

OK, but it seems still without my last patch to ifb?

Thanks,
Jarek P.
