From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Tue, 19 Aug 2014 21:36:25 +0200
Message-ID: <53F3A739.4070203@ahsoftware.de>
References: <52A75EF8.3010308@in.tum.de>	 <20131211.150137.368953964178408437.davem@davemloft.net>	 <52A8C8B4.4060109@in.tum.de>	 <20131211122637.75b09074@nehalam.linuxnetplumber.net>	 <87bo0nulkt.fsf@tassilo.jf.intel.com> <52A8ECF5.3070604@in.tum.de>	 <20131212012317.GL21717@two.firstfloor.org>	 <52A98DBF.4090702@appelbaum.net> <52A9A17F.6050505@in.tum.de> <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, knock@gnunet.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Grothoff <grothoff@in.tum.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:37975 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbaHSTgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 15:36:45 -0400
In-Reply-To: <1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 12.12.2013 15:34, schrieb Eric Dumazet:

A bit late, but I've just stumbled over that feature which I do like a lot.

> Very soon you'll need to support different secrets. You do not want all
> clients share a common secret, do you ? How can a server change its
> secret without disrupting clients ?

Impossible because you already need a channel if you want to identify 
the client. But that isn't the intention of the patch. You still have 
the usual authentication stuff in the service you want to hide. It's 
about hiding (from someone outside a closed group) the possibility to 
authenticate.

> How having a constant initial sequence number can even be valid ?
> What about TCP timestamps being not available at all ?
> How typical servers can be behind a load balancer ?
> Or am I missing something ?

It doesn't have to work in every environment and it doesn't have to 
solve all existing problems in the world. ;)

But it enables people to protect a bit more against malicious people or 
governments.

And it is really very easy to use. It took me around half an hour to 
find the places in openvpn and openssh where I had to add the 
setsockopt() call and it can be used even easier with preloading 
libknockify.so.

There can be found much more useless options in the kernel. At least I 
like it and it fits my needs too.

Regards,

Alexander Holler
