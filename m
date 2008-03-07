From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 19:25:00 -0500
Message-ID: <1204849500.4431.39.camel@localhost>
References: <20080225095646.GA4321@ff.dom.local>
	 <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local>
	 <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local>
	 <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost>
	 <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local>
	 <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local>
	 <20080306233151.M43262@visp.net.lb> <1204848599.4431.33.camel@localhost>
	 <20080307001432.M85916@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.177]:23289 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbYCGAZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 19:25:04 -0500
Received: by el-out-1112.google.com with SMTP id v27so226614ele.17
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 16:25:04 -0800 (PST)
In-Reply-To: <20080307001432.M85916@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-07-03 at 02:15 +0200, Denys Fedoryshchenko wrote:
> I just start to using lockdep on servers with shaper over ifb from 2.6.24. So 
> it is triggering from 2.6.24 till latest 2.6.25-rc4. If you want - i can 
> build some specific old version of kernel with lockdep.

I think i should be able to try with your .config first with the latest
git. I should be able to at least see the traces.

I am just going to compile some things into the kernel, example:

---
CONFIG_IFB=m
CONFIG_DUMMY=m
CONFIG_BONDING=m
CONFIG_MACVLAN=m
CONFIG_EQUALIZER=m
CONFIG_TUN=m
----

Can you try that as well? Then if it doesnt happen with me, we'll narrow it to need for
smp.

cheers,
jamal

