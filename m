From: Markus <fingon@iki.fi>
Subject: Re: IPv6 routing type - not at par with IPv4 one?
Date: Thu, 6 Sep 2012 13:54:51 +0300
Message-ID: <7F0FC925-D0A4-4E27-AE8A-F2E0A619FB36@iki.fi>
References: <loom.20120906T115737-277@post.gmane.org> <1346927705.2484.22.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.0 \(1486\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Markus Stenberg <markus.stenberg@iki.fi>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out.inet.fi ([195.156.147.13]:39030 "EHLO kirsi2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062Ab2IFKy4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 06:54:56 -0400
In-Reply-To: <1346927705.2484.22.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6.9.2012, at 13.35, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Well, it  seems you missed this : 
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=commitdiff;h=ef2c7d7b59708d54213c7556a82d14de9a7e4475
> 
> At least the blackhole is now supported on IPv6, so you probably have to
> add the 'throw' bit, if it makes any sense.


Ah, cool, teaches me to refresh my git trees before posting ;-)
Nicolas, want to update for that too or will I? 

Throw is useful in various cases (it is RTN_THROW / -EAGAIN). 

Cheers,

-Markus