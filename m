From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: strange tcp behavior
Date: Fri, 3 Aug 2007 21:39:06 +0400
Message-ID: <20070803173906.GA30688@2ka.mipt.ru>
References: <48738.simon.1186056932@5ec7c279.invalid> <46B21148.2090004@simon.arlott.org.uk> <20070802180842.GA6864@2ka.mipt.ru> <46B2293B.3020406@simon.arlott.org.uk> <20070803082517.GB25582@2ka.mipt.ru> <46956.simon.1186140106@5ec7c279.invalid> <20070803115624.GD5727@2ka.mipt.ru> <60580.simon.1186142626@5ec7c279.invalid> <20070803120920.GA23166@2ka.mipt.ru> <46B35D1E.9050501@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@screen.lv, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57531 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759279AbXHCRlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 13:41:31 -0400
Content-Disposition: inline
In-Reply-To: <46B35D1E.9050501@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 03, 2007 at 05:51:42PM +0100, Simon Arlott (simon@fire.lp0.eu) wrote:

> 17:38:03.533589 IP 192.168.7.4.50550 > 192.168.7.8.2500: R 82517592:82517592(0) win 1500 (raw)
> vs
> 17:37:38.383085 IP 192.168.7.8.2500 > 192.168.7.4.50550: R 4259643274:4259643274(0) ack 1171836829 win 14360
> What happened there ?

You mean what will happend if second rst (4259643274) is close enough to
first (82517592) to reset the connection? If this will be session hijiking
attack first (known) implemented by Kevin Mitnik. So far things moved
forward and sequence number generation algorithm changed a lot.
It is the same situation, which would happen if you will spam remote
side with RST packets with arbitrary sequence number in hope that it
will reset some connection.


-- 
	Evgeniy Polyakov
