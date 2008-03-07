From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 7 Mar 2008 02:15:37 +0200
Message-ID: <20080307001432.M85916@visp.net.lb>
References: <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb> <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb> <20080306202551.GB2876@ami.dom.local> <1204837000.4457.108.camel@localhost> <20080306221253.GD2876@ami.dom.local> <20080306233151.M43262@visp.net.lb> <1204848599.4431.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:58573 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756615AbYCGAPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 19:15:55 -0500
In-Reply-To: <1204848599.4431.33.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just start to using lockdep on servers with shaper over ifb from 2.6.24. So 
it is triggering from 2.6.24 till latest 2.6.25-rc4. If you want - i can 
build some specific old version of kernel with lockdep.

On Thu, 06 Mar 2008 19:09:59 -0500, jamal wrote
> Denys,
> 
> On Fri, 2008-07-03 at 01:43 +0200, Denys Fedoryshchenko wrote:
> > About reproducing, I think .config matter
> > Mine is at http://www.nuclearcat.com/files/config.txt
> >
> 
> Ok, that + SMP is what i am lacking. Given i am in travel mode i will
> not be able to try it out on SMP for a few days but i will try to build
> the kernel with your config. My initial test with latest git also seems
> to fail to reproduce it.
> 
> In any case, i think the lockdep alarm is false positive.
> 
> One thing i couldnt figure from your emails is whether you saw the
> traces on the latest kernels or it has always been there.
> 
> cheers,
> jamal
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

