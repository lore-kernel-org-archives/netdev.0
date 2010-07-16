From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Enhance dev_ioctl to return <hwaddr>:<if_name::if_index>
 mapping
Date: Fri, 16 Jul 2010 12:40:31 -0700 (PDT)
Message-ID: <20100716.124031.220080717.davem@davemloft.net>
References: <AANLkTin3V7LtmhDAOktNF1UITM86sJwButxCQ3vo31lv@mail.gmail.com>
	<20100716.123306.232886890.davem@davemloft.net>
	<AANLkTilhSSh1kE5ZfqVDbBJJWdP3hDcXRffpQwdyMQua@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Chetan.Loke@netscout.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: chetanloke@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53359
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758894Ab0GPTkP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 15:40:15 -0400
In-Reply-To: <AANLkTilhSSh1kE5ZfqVDbBJJWdP3hDcXRffpQwdyMQua@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chetan Loke <chetanloke@gmail.com>
Date: Fri, 16 Jul 2010 15:35:48 -0400

> Yes, I opened a socket and then sent the IFCONF ioctl.What I meant was
> that interfaces that didn't have an IP weren't returned.

If you use the correct set of ioctl()'s it will, just as
"/sbin/ifconfig -a" lists all interfaces regardless of whether they
have IP addresses.

Run strace on 'ifconfig', see what it does :-)

And then you also have the option of using netlink as well.
This is how "ip l l" lists all interfaces, also regardless of
configuration.
