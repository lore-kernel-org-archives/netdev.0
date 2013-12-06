From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Fri, 06 Dec 2013 12:10:04 -0500 (EST)
Message-ID: <20131206.121004.406077340286411332.davem@davemloft.net>
References: <CAJ7VeQwC7xPPujCN8kQ3KcJAhykwQXLFA=vw2gWABmpUvuz1og@mail.gmail.com>
	<1386264770.30495.204.camel@edumazet-glaptop2.roam.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sekletar.m@gmail.com, dborkman@redhat.com,
	msekleta@redhat.com, netdev@vger.kernel.org, mtk.manpages@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab3LFRKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 12:10:06 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7466@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 6 Dec 2013 09:50:49 -0000

>> if SO_BPF_EXTENSIONS is supported, than you can assume that all current
>> extensions are supported.
>> 
>> No need to consume one bit per feature, as all these features wont ever
>> disappear from linux.
> 
> However one of the BSDs could add a subset of the features and
> wish to advertise the fact.
> So using extra flags for non-trivial extensions could be useful.

Sorry, we're not going to accomodate this.
