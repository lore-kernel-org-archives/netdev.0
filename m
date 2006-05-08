From: Rick Jones <rick.jones2@hp.com>
Subject: Re: IPv6 connect() from site-local to global IPv6 address.
Date: Mon, 08 May 2006 09:44:38 -0700
Message-ID: <445F7576.5080102@hp.com>
References: <1146862832.2766.54.camel@pmac.infradead.org>	<20060506.091920.122414672.yoshfuji@linux-ipv6.org>	<1146876802.2503.32.camel@shinybook.infradead.org>	<20060506.113904.63157190.yoshfuji@linux-ipv6.org> <1146926830.2503.67.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:11417 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S932365AbWEHQok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 12:44:40 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1146926830.2503.67.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>Anyway, it is valid to use (obsolete) site-local source address
>>for global destination address.
>>The problem seems that router does NOT send ICMPv6 destination
>>unreachable to the sender. I don't know why, but it SHOULD. 
> 
> 
> I'll pursue that question later. It wouldn't be _sufficient_ since there
> are (buggy) programs, including Evolution, which will not fall back to
> the second and subsequent addresses from getaddrinfo() -- they'll just
> give up when the first attempt to connect fails. So we really do need
> the IPv4 address to be listed _first_ in the results, as it used to be.

Or get the applications fixed no?  Kludging around application bugs 
sounds a bit like the "Fram Oil Filter" commercial where the mechanic is 
grinning while he says "You can pay me now, or you can pay be later." As 
in pay for the slightly more expensive oil filter now, or engine repair 
later.

> I wish to deploy IPv6 internally so that we can develop and test IPv6
> support. There is _no_ chance of getting proper IPv6 connectivity to the
> outside world through the corporate firewall. I'd like IPv6 to be usable
> _internally_ though, without breaking connectivity to the outside world
> over IPv4.
> 
> How should I do this?

Other than fixing the applications that only take the first response 
(isn't that a generic application bug going back nearly decades now? 
amazing how things stay the same isn't it) Can you run a caching-only 
name server at the edge that filters-out the IPv6 responses so your 
systems never see Global IPV6 responses?

rick jones
