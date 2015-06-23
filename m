From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Tue, 23 Jun 2015 19:21:30 +0200
Message-ID: <5589959A.8060600@hartkopp.net>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>	<557DCD0A.5040500@hartkopp.net>	<557DD20E.4080005@hartkopp.net>	<557E7D89.30301@6wind.com>	<557E9728.7080208@6wind.com> <20150615085410.6628b5bb@urahara> <55805E6A.90805@hartkopp.net> <5581210D.5070901@6wind.com> <5585F005.6060408@hartkopp.net> <558955A0.7040203@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.161]:56356 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729AbbFWRVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 13:21:52 -0400
In-Reply-To: <558955A0.7040203@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.06.2015 14:48, Nicolas Dichtel wrote:

>> E.g. virtual CAN interfaces (vcan.c) now print this @NONE and they never have
>> a (physical?) link. So you probably have to deal with different virtual
>> interfaces anyway, right?
> Yes, with the current code, all virtual interfaces (that define a
> rtnl_link_ops) will have this "@SOMETHING" because IFLA_LINK is now set to 0.

Just for the records:

Virtual and real CAN network interfaces (the stuff in drivers/net/can) also
have @NONE displayed in their name:

# ip link show
(..)
6: vcan0@NONE: <NOARP,UP,LOWER_UP> mtu 72 qdisc noqueue state UNKNOWN mode DEFAULT group default 
    link/can 
(..)
8: can0@NONE: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UNKNOWN mode DEFAULT group default qlen 10
    link/can 
(..)

So at least your distinction real/virtual networking interfaces doesn't match
for all kind of interfaces.

Regards,
Oliver
