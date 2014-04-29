From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: Re: [PATCH RFC 2/2] net: qualcomm: new Ethernet over SPI driver for
 QCA7000
Date: Tue, 29 Apr 2014 17:54:12 +0200
Message-ID: <535FCB24.2010507@i2se.com>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <5020765.3GuR21cUpi@wuerfel> <535F4BEE.4080300@i2se.com> <4860368.6Apskanc4s@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:49192 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758010AbaD2PyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 11:54:25 -0400
In-Reply-To: <4860368.6Apskanc4s@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am 29.04.2014 10:14, schrieb Arnd Bergmann:
> i think it's more important to use standard interfaces here. A random
> user trying to debug a problem with this hardware may know about
> ethtool or find that documented somewhere, but wouldn't know about the
> debugfs interfaces without reading the driver source code. The ethtool
> interface is also easier to maintain than the debugfs files. 

okay, i'll try it.

> As far as I know it's also not mandatory.
>
> If the hardware interfaces require calling sleeping functions, it
> may not actually be possible, but if you can use it, it normally
> provides better performance.

As i understood NAPI is good for high load on 1000 MBit ethernet, but
the QCA7000 has
in best case only a 10 MBit powerline connection. Additionally these
packets must be transfered
over a half duplex SPI. So i think the current driver implementation
isn't a bottle neck.

>
>> Does this mean the current state of the driver should better go to staging?
> Probably not, the driver doesn't look bad overall.
>
> 	Arnd
>

I'm relieved to hear that. Thanks for your comments.

Stefan<http://dict.leo.org/#/search=that.&searchLoc=0&resultOrder=basic&multiwordShowSingle=on>
