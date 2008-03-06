From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 08:59:55 -0500
Message-ID: <1204811995.4440.30.camel@localhost>
References: <20080224222035.M62480@visp.net.lb>
	 <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
	 <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb>
	 <20080306134015.GA4571@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:9205 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759362AbYCFN77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 08:59:59 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1255312rvb.1
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 05:59:57 -0800 (PST)
In-Reply-To: <20080306134015.GA4571@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-03 at 13:40 +0000, Jarek Poplawski wrote:

> I'm not sure this lockdep report is because of this, but there is
> really a problem with lock order while using sch_ingress with
> act_mirred: dev->queue_lock is taken after dev->ingress_lock, so
> reversely to e.g. qdisc_lock_tree(). This shouldn't be a problem
> when one of the devices is ifb yet.

Are there more details? Ingress of which netdevice is redirecting to
egress of which netdevice?
Sorry, I dont understand much about the internals of lockdep so i dont
know what you are teaching it in the patch below...

cheers,
jamal

