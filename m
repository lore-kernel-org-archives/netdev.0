From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 19:09:59 -0500
Message-ID: <1204848599.4431.33.camel@localhost>
References: <20080225095646.GA4321@ff.dom.local>
	 <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local>
	 <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local>
	 <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost>
	 <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local>
	 <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local>
	 <20080306233151.M43262@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:54948 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbYCGAKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 19:10:04 -0500
Received: by el-out-1112.google.com with SMTP id v27so216498ele.17
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 16:10:02 -0800 (PST)
In-Reply-To: <20080306233151.M43262@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys,

On Fri, 2008-07-03 at 01:43 +0200, Denys Fedoryshchenko wrote:
> About reproducing, I think .config matter
> Mine is at http://www.nuclearcat.com/files/config.txt
> 

Ok, that + SMP is what i am lacking. Given i am in travel mode i will
not be able to try it out on SMP for a few days but i will try to build
the kernel with your config. My initial test with latest git also seems
to fail to reproduce it.

In any case, i think the lockdep alarm is false positive.

One thing i couldnt figure from your emails is whether you saw the
traces on the latest kernels or it has always been there.

cheers,
jamal

