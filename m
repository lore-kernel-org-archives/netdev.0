From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET]: gen_estimator deadlock fix
Date: Mon, 16 Jul 2007 15:03:32 +0200
Message-ID: <469B6CA4.9030205@trash.net>
References: <1184161297.1141.53.camel@ranko-fc2.spidernet.net> <20070712073746.GA1708@ff.dom.local> <1184231903.3477.65.camel@ranko-fc2.spidernet.net> <20070712104641.GB1708@ff.dom.local> <1184240842.3477.110.camel@ranko-fc2.spidernet.net> <46961970.7080209@trash.net> <1184262525.3477.135.camel@ranko-fc2.spidernet.net> <20070713121733.GB3282@ff.dom.local> <1184329602.16732.16.camel@ranko-fc2.spidernet.net> <20070713134231.GC3282@ff.dom.local> <20070716070032.GA1871@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ranko Zivojnovic <ranko@spidernet.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49766 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756370AbXGPNFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:05:04 -0400
In-Reply-To: <20070716070032.GA1871@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> There is probably quite easy way to get rid of this one race only
> by e.g. replacing *bstats field with NULL in gen_kill_estimator,
> and check for this in est_timer just after taking a lock.
> 
> The gain from an api change would be mainly faster gen_kill_
> and gen_replace_estimator. But, on the other hand, you have it
> almost done. Ranko, I think these changes need opinion of more
> maintainers as soon as possible - after all they could have some
> objections; IMHO at least: Jamal Hadi Salim, Thomas Graf (authors
> plus act_), Stephen Hemminger (sch_netem) and Jiri Benc
> (net/mac80211).


Frankly, all we need is a final patch.
