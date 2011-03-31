From: Stefan Bigler <stefan.bigler@keymile.com>
Subject: DSA for the 88e6061 switch
Date: Thu, 31 Mar 2011 09:35:09 +0200
Message-ID: <4D942EAD.9010102@keymile.com>
Reply-To: stefan.bigler@keymile.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ch.keymile.com ([193.17.201.103]:50286 "HELO
	mail.ch.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750739Ab1CaHqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 03:46:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

we would like to implement DSA for the 88e6061 switch, mainly to manage
the phys of the various switch ports. Unfortunately, this switch seems
only to supports the Marvell Header tagging mode but not the Trailer or
DSA mode. The Header mode has the disadvantage, that the tagging bytes
are inserted in*front*  of the MAC header which most Ethernet
controllers do not like because it's used for RX filtering and TX length
padding. This could be worked around by using promiscuous mode and doing
TX length padding in software, but that's not a really good solution.
This rises the following questions:

- Are there other tagging methods which could be used for the 88e6061
   switch?

- Is there an interface to manage the phys of the various ports
*without*  an associated netdev device, e.g. using ethtool directly
   over the mdio bus?

Any help is appreciated.

Thanks,
Stefan
