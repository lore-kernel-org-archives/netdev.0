From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Thu, 12 Jul 2007 14:07:12 +0200
Message-ID: <46961970.7080209@trash.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net>	 <20070712073746.GA1708@ff.dom.local>	 <1184231903.3477.65.camel@ranko-fc2.spidernet.net>	 <20070712104641.GB1708@ff.dom.local> <1184240842.3477.110.camel@ranko-fc2.spidernet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org
To: Ranko Zivojnovic <ranko@spidernet.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45536 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbXGLMHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 08:07:33 -0400
In-Reply-To: <1184240842.3477.110.camel@ranko-fc2.spidernet.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Removed Andrew from CC]

Ranko Zivojnovic wrote:
> I agree - it does look like the most sensible thing to do - have
> gnet_stats_basic and gnet_stats_rate_est allocated within the
> gen_estimator struct rather than pointers looking here and there - and
> provide api to maintain those stats - it simplifies the picture.


The API is not very pretty, some improvement there would be welcome.

> Also - the stats_lock in this case could be local to gen_estimator
> struct, thus making the implementation completely "dev agnostic" - and
> will not break on dev removal.


The queue lock is used since thats what protects the qdisc counters.
