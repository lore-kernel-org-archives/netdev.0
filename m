From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 15:56:40 -0500
Message-ID: <1204837000.4457.108.camel@localhost>
References: <20080224222035.M62480@visp.net.lb>
	 <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
	 <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb>
	 <20080306134015.GA4571@ff.dom.local> <20080306135625.M25627@visp.net.lb>
	 <1204813634.4440.59.camel@localhost> <20080306143910.M91001@visp.net.lb>
	 <20080306202551.GB2876@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.181]:38521 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765663AbYCFU4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 15:56:46 -0500
Received: by el-out-1112.google.com with SMTP id v27so80175ele.17
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 12:56:44 -0800 (PST)
In-Reply-To: <20080306202551.GB2876@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-03 at 21:25 +0100, Jarek Poplawski wrote:

> It's really strange: I can't reproduce this, 

I couldnt either - are you using 2.6.25-rc4?

> and if it were so easy we
> would get really a lot of similar reports. It looks like you have
> something special. This lockdep report with this kind of problem
> usually looks different too. The good side is it's easy to reproduce.
> So, could you try the patch below? (It's only supposed to fix the lockdep
> warning, not lockups).

This is more out of ignorance: Why is ifb needing the extra teaching for
lockdep? It is a netdevice - shouldnt the two global lockdeps you
described earlier not be sufficient?

cheers,
jamal

