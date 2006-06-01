From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Question about tcp hash function tcp_hashfn()
Date: Thu, 1 Jun 2006 10:30:13 +0400
Message-ID: <20060601063012.GC28087@2ka.mipt.ru>
References: <20060531090301.GA26782@2ka.mipt.ru> <20060531035124.B3065@openss7.org> <20060531105814.GB7806@2ka.mipt.ru> <20060531.114127.14356069.davem@davemloft.net> <20060601060424.GA28087@2ka.mipt.ru> <20060601001825.A21730@openss7.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Brian F. G. Bidulock" <bidulock@openss7.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44250 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965267AbWFAGa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 02:30:57 -0400
To: David Miller <davem@davemloft.net>, draghuram@rocketmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060601001825.A21730@openss7.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 01, 2006 at 12:18:25AM -0600, Brian F. G. Bidulock (bidulock@openss7.org) wrote:
> Evgeniy,
> 
> On Thu, 01 Jun 2006, Evgeniy Polyakov wrote:
> > 	
> > 	for (i=0; i<hash_size*iter_num; ++i) {
> > 		saddr = num2ip(get_random_byte(), get_random_byte(), get_random_byte(), get_random_byte());
> > 		sport = get_random_word();
> 
> You still have a problem: you cannot use a pseudo-random number
> generator to generate the sample set as the pseudo-random number
> generator function itself can interact with the hash.
> 
> Try iterating through all 2**48 values or at least a sizeable
> representative subset.

Since pseudo-randomness affects both folded and not folded hash
distribution, it can not end up in different results.

You are right that having test with 2^48 values is really interesting,
but it will take ages on my test machine :)

-- 
	Evgeniy Polyakov
