From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Fri, 7 Mar 2008 08:32:51 +0000
Message-ID: <20080307083251.GB3912@ff.dom.local>
References: <20080225104652.M2446@visp.net.lb> <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb> <20080306134015.GA4571@ff.dom.local> <1204811995.4440.30.camel@localhost> <20080306175629.GA2876@ami.dom.local> <1204836523.4457.103.camel@localhost> <20080306214000.GC2876@ami.dom.local> <1204846839.4431.23.camel@localhost> <20080307075113.GA3912@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:46168 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754030AbYCGIbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 03:31:32 -0500
Received: by ug-out-1314.google.com with SMTP id z38so4246997ugc.16
        for <netdev@vger.kernel.org>; Fri, 07 Mar 2008 00:31:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080307075113.GA3912@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 07, 2008 at 07:51:13AM +0000, Jarek Poplawski wrote:
...
> I've to find first what really bothers lockdep here, and why this
> queue_lock vs. ingress_lock order isn't reported "by default". But if
> this really is like it looks now, then it seems before doing this
> ingress "future point" some change in locking could be necessary.
> (Maybe even sooner if lockdep finds something real after this current
> patch to ifb.)

Actually, I got it a bit wrong: "the problem" with ifb could probably
exist now: if we would redirect e.g. from ifb0's ingress to eth0's
egress, while doing the same thing from eth0 to ifb0. But can we get
any traffic on ifb0's ingress? And why would we do this after all?

Jarek P.
